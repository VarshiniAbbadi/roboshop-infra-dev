module "frontend" {
    source = "git::https://github.com/VarshiniAbbadi/terraform-aws-roboshop.git?ref=main"
    component = "frontend"
    rule_priority = 10
}