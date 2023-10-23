resource "aws_sesv2_email_identity" "example" {
  email_identity = var.email
}

resource "aws_iam_user" "webatspeed_smtp_user" {
  name = "smtp_user"
}

resource "aws_iam_access_key" "webatspeed_iam_access_key" {
  user = aws_iam_user.webatspeed_smtp_user.name
}

data "aws_iam_policy_document" "webatspeed_iam_ses_policy_document" {
  statement {
    actions   = ["ses:SendEmail", "ses:SendRawEmail", "ses:SendTemplatedEmail"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "webatspeed_iam_ses_policy" {
  name        = "ses_sender"
  description = "Allows sending of e-mails via Simple Email Service"
  policy      = data.aws_iam_policy_document.webatspeed_iam_ses_policy_document.json
}

resource "aws_iam_user_policy_attachment" "webatspeed_iam_ses_policy_attachment" {
  user       = aws_iam_user.webatspeed_smtp_user.name
  policy_arn = aws_iam_policy.webatspeed_iam_ses_policy.arn
}

//noinspection HILUnresolvedReference
resource "aws_ses_template" "webatspeed_ses_templates" {
  for_each = var.email_templates

  name    = each.value.name
  subject = each.value.subject
  text = join("\n", [
    for fn in ["${path.module}/templates/${each.value.name}.txt", "${path.module}/templates/footer.txt"] : file(fn)
  ])
  html = join("\n", [
    for fn in ["${path.module}/templates/${each.value.name}.html", "${path.module}/templates/footer.html"] : file(fn)
  ])
}
