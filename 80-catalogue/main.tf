module "catalogue" {
    source = "git::https://github.com/VarshiniAbbadi/terraform-aws-roboshop.git?ref=main"
    component = "catalogue"
    rule_priority = 10
}