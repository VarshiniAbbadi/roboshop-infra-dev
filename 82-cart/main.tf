module "cart" {
    source = "git::https://github.com/VarshiniAbbadi/terraform-aws-roboshop.git?ref=main"
    component = "cart"
    rule_priority = 30
}