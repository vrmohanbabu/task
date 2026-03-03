output "vpi_id" {
    value = aws_vpc.DemoVPC.id
}

output "igw_id" {
    value = aws_internet_gateway.DemoIGW.id
}

output "pub_az1_id" {
    value = aws_subnet.PublicSubnetA.id
}

output "pub_az2_id" {
    value = aws_subnet.PublicSubnetB.id
}

output "pri_az1_id" {
    value = aws_subnet.PrivateSubnetA.id
}

output "pri_az2_id" {
    value = aws_subnet.PrivateSubnetB.id
}

output "pub_route_table" {
    value = aws_route_table.PrivateRouteTable.id
}

output "pri_route_table" {
    value = aws_route_table.PrivateRouteTable.id
}