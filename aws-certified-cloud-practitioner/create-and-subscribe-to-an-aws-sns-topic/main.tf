resource "aws_sns_topic" "topic" {
  name = "EC2State"
}

resource "aws_sns_topic_subscription" "topic_subscription" {
  endpoint  = "vanio.begic123@gmail.com"
  protocol  = "email"
  topic_arn = aws_sns_topic.topic.arn
}

resource "aws_cloudwatch_metric_alarm" "status_check_alarm" {
  alarm_name          = "StatusCheckAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold = 0
  period = "60"
  treat_missing_data = "breaching"
  evaluation_periods  = 1
  namespace = "AWS/EC2"
  metric_name = "CPUUtilization"
  statistic = "Maximum"
  alarm_actions = [aws_sns_topic.topic.arn]

  dimensions = {
    InstanceId = module.public-instance.instance_id
  }
}

module "public-instance" {
  source = "../../modules/public-ec2-instance"
  private_key_file_path = "${path.module}/key.pem"
}