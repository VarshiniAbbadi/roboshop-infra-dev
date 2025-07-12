module "payment" {
    source = "git::https://github.com/VarshiniAbbadi/terraform-aws-roboshop.git?ref=main"
    component = "payment"
    rule_priority = 50
}