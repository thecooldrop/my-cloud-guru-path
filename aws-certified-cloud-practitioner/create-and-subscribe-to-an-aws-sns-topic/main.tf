resource "aws_sns_topic" "topic" {
  name = "EC2State"
}

resource "aws_sns_topic_subscription" "topic_subscription" {
  endpoint  = "vanio.begic123@gmail.com"
  protocol  = "email"
  topic_arn = aws_sns_topic.topic.arn
}

resource "aws_cloudwatch_metric_alarm" "" {
  alarm_name          = ""
  comparison_operator = ""
  evaluation_periods  = 0
}