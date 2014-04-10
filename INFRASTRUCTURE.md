# Lynr.co Infrastructure

This document provides information about the infrastructure supporting [lynr-co][lynr]
and if different [lynr-co-stage][lynr-stage]. The goal of this document is to provide
an overview of how the pieces fit together so it exists somewhere other than the
developer's head.

[lynr]: https://www.lynr.co
[lynr-stage]: https://lynr-co-stage.herokuapp.com

## AMQP

We are using [CloudAMQP][cloudamqp] as the hosting provider for [RabbitMQ][rabbitmq].
RabbitMQ is a rock solid piece of software well suited to passing ephemeral messages
between disparate parts of the application. Using a SaaS provider for this allows
more focus on development and less focus on infrastructure which is a common
theme in this document.

Generally, lynr-co-stage does not have a 'worker' process running so background
jobs are not being processed. There is a CloudAMQP instance running for staging
but it is the smallest plan type. The AMQP instance for lynr-co has a pool of
twelve (12) connections available for use.

[cloudamqp]: http://www.cloudamqp.com
[rabbitmq]: http://www.rabbitmq.com

## Email Delivery

System emails are being processed through [Mailgun][mailgun]. The appropriate SPF
and DKIM DNS records have been setup to permit Mailgun to send email on behalf of
the lynr.co domain. Mailgun has a straightforward REST API to enable sending emails.

[mailgun]: http://www.mailgun.com

## Search

Search queries are being processed by [Elasticsearch][es] hosted by [Found][found].
Elasticsearch is powered by [Lucene][lucene] which is a powerful full-text indexing
library and server. There are separate clusters running for the lynr-co-stage and
lynr-co applications.

[es]: http://elasticsearch.org
[found]: https://www.found.no
[lucene]: https://lucene.apache.org
