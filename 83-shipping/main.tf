module "shipping" {
    source = "git::https://github.com/VarshiniAbbadi/terraform-aws-roboshop.git?ref=main"
    component = "shipping"
    rule_priority = 40
}