provider "aws" {

  region = "us-east-1"

}

resource "aws_vpc" "vpc_dperez" {
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true
    tags ={
        Nmame= "vpc_dperez"
        project = "rampup_daniel"
        responsible = "dperez@psl.com.co"
    }
  
}

# Public subnet elements
resource "aws_subnet" "publica_dperezg" {
    vpc_id = "${aws_vpc.vpc_dperez.id}"
    cidr_block = "10.0.1.0/24"

    tags ={
        Name = "publica_dperezg"
        project = "rampup_daniel"
        responsible = "dperez@psl.com.co"
    }
}

resource "aws_internet_gateway" "gw_public" {
    vpc_id= "${aws_vpc.vpc_dperez.id}"

    tags ={
        Name = "GW_dperezg"
        project = "rampup_daniel"
        responsible = "dperez@psl.com.co"
    }
  
}
resource "aws_route_table" "route_table_dperezg" {
    vpc_id = "${aws_vpc.vpc_dperez.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.gw_public.id}"
    }

    tags = {
        Name = "pubroutetable_dperezg"
        project = "rampup_daniel"
        responsible = "dperez@psl.com.co"
    }
}

resource "aws_main_route_table_association" "pubroute_association" {
      vpc_id= "${aws_vpc.vpc_dperez.id}"
     route_table_id ="${aws_route_table.route_table_dperezg.id}"
}

resource "aws_instance" "nat" {
    ami = "ami-0833d29454717ff52" 
    instance_type = "t2.micro"
    key_name = "dperezg-kp"
    vpc_security_group_ids = ["${aws_security_group.nat.id}"]
    subnet_id = "${aws_subnet.publica_dperezg.id}"
    associate_public_ip_address = true
    tags = {
        Name = "natinst_dperez"
        project = "rampup_daniel"
        responsible = "dperez@psl.com.co"
    }
}

resource "aws_instance" "jenkins" {
    ami = "ami-0b898040803850657" 
    instance_type = "t2.micro"
    key_name = "dperezg-kp"
    vpc_security_group_ids = ["${aws_security_group.frontend_SG.id}"]
    subnet_id = "${aws_subnet.publica_dperezg.id}"
    associate_public_ip_address = true
    tags = {
        Name = "jenkins_dperez"
        project = "rampup_daniel"
        responsible = "dperez@psl.com.co"
    }
}
resource "aws_eip" "nat_ip" {
   instance = "${aws_instance.nat.id}"
      tags ={
        project = "rampup_daniel"
        responsible = "dperez@psl.com.co"
    }

}
resource "aws_launch_configuration" "conf_frot" {
  image_id      = "ami-0b898040803850657"
  instance_type = "t2.micro"
  security_groups=["${aws_security_group.frontend_SG.id}"]
  associate_public_ip_address=true
  key_name="dperezg-kp"
  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_autoscaling_group" "auto_scaling_front" {
  launch_configuration = "${aws_launch_configuration.conf_frot.id}"
  min_size             = 1
  max_size             = 2
  vpc_zone_identifier=["${aws_subnet.publica_dperezg.id}"]
    load_balancers = ["${aws_elb.elbfront.id}"]
  lifecycle {
    create_before_destroy = true
  }       
  }

resource "aws_elb" "elbfront" {
  name               = "elbfront"
  subnets= ["${aws_subnet.publica_dperezg.id}"]
    security_groups=["${aws_security_group.frontend_SG.id}"]

  listener {
    instance_port     = 3000
    instance_protocol = "http"
    lb_port           = 3000
    lb_protocol       = "http"
  }
        tags ={
        project = "rampup_daniel"
        responsible = "dperez@psl.com.co"
    }
  }
resource "aws_security_group" "nat" {
    name = "vpc_nat"
    description = "Allow traffic to pass from the private subnet to the internet"
    ingress {
        from_port = 3000
        to_port = 3000
        protocol = "tcp"
        cidr_blocks = ["${aws_subnet.publica_dperezg.cidr_block}"]
    }
    ingress {
        from_port = 3000
        to_port = 3000
        protocol = "udp"
        cidr_blocks = ["${aws_subnet.publica_dperezg.cidr_block}"]
    }

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 3000
        to_port = 3000
        protocol = "tcp"
        cidr_blocks = ["${aws_subnet.publica_dperezg.cidr_block}"]
    }
        egress {
        from_port = 3000
        to_port = 3000
        protocol = "udp"
        cidr_blocks = ["${aws_subnet.publica_dperezg.cidr_block}"]
    }

    egress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${aws_vpc.vpc_dperez.cidr_block}"]
    }
    egress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    vpc_id = "${aws_vpc.vpc_dperez.id}"
        
    tags ={
        project = "rampup_daniel"
        responsible = "dperez@psl.com.co"
    }

}

resource "aws_security_group" "frontend_SG" {

description = "allow all"
    vpc_id = "${aws_vpc.vpc_dperez.id}"
  
     ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
        egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
      tags ={
        project = "rampup_daniel"
        responsible = "dperez@psl.com.co"
    }
}

#subnet privada 

resource "aws_subnet" "private_subnet" {
  vpc_id = "${aws_vpc.vpc_dperez.id}"
    cidr_block = "10.0.2.0/24"
    
    tags ={
        project = "rampup_daniel"
        responsible = "dperez@psl.com.co"
    }
}

resource "aws_route_table" "RT_privada" {
    vpc_id = "${aws_vpc.vpc_dperez.id}"
    route {
        cidr_block = "0.0.0.0/0"
        instance_id = "${aws_instance.nat.id}"
    }

    tags= {
        project = "rampup_daniel"
        responsible = "dperez@psl.com.co"
    }
}

resource "aws_route_table_association" "rt_association_priv" {
    subnet_id = "${aws_subnet.private_subnet.id}"
    route_table_id = "${aws_route_table.RT_privada.id}"

}



resource "aws_launch_configuration" "conf_back" {
  image_id      = "ami-0b898040803850657"
  instance_type = "t2.micro"
  security_groups=["${aws_security_group.frontend_SG.id}"]
  key_name="dperezg-kp"
  lifecycle {
    create_before_destroy = true
  }
        }
resource "aws_autoscaling_group" "auto_scaling_backt" {
  launch_configuration = "${aws_launch_configuration.conf_back.id}"
  min_size             = 1
  max_size             = 2
  vpc_zone_identifier=["${aws_subnet.private_subnet.id}"]
    load_balancers = ["${aws_elb.elbback.id}"]
  lifecycle {
    create_before_destroy = true
  }
  }

resource "aws_elb" "elbback" {
  name               = "elbback"
  subnets= ["${aws_subnet.private_subnet.id}"]
    security_groups=["${aws_security_group.frontend_SG.id}"]

  listener {
    instance_port     = 3000
    instance_protocol = "http"
    lb_port           = 3000
    lb_protocol       = "http"
  }
  
        tags = {
        project = "rampup_daniel"
        responsible = "dperez@psl.com.co"
        }
        }
