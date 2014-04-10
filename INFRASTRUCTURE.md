# Lynr.co Infrastructure

This document provides information about the infrastructure supporting [lynr-co][lynr] and if different [lynr-co-stage][lynr-stage]. The goal of this document is to provide an overview of how the pieces fit together so it exists somewhere other than the developer's head.

[lynr]: https://www.lynr.co
[lynr-stage]: https://lynr-co-stage.herokuapp.com

## AMQP

We are using [CloudAMQP][cloudamqp] as the hosting provider for [RabbitMQ][rabbitmq]. RabbitMQ is a rock solid piece of software well suited to passing ephemeral messages between disparate parts of the application. Using a SaaS provider for this allows more focus on development and less focus on infrastructure which is a common theme in this document.

Presently (as of 2014-03-15) both lynr-co and lynr-co-stage are served by the same CloudAMQP instance. There is only one worker process running and both write to the same Queues on CloudAMQP, meaning both lynr-co and lynr-co-stage place messages in the same Queue and the single worker processes them. There is some **risk** associated with this stragegy if new types of `Lynr::Queue::Job` messages are published to the Queue before the lynr-co worker process knows how to process them.

[cloudamqp]: http://www.cloudamqp.com
[rabbitmq]: http://www.rabbitmq.com

## Email Delivery

System emails are being processed through [Mailgun][mailgun]. The appropriate SPF and DKIM DNS records have been setup to permit Mailgun to send email on behalf of the lynr.co domain. Mailgun has a straightforward REST API to enable sending emails.

[mailgun]: http://www.mailgun.com

## Search

Search queries are being processed by [Elasticsearch][es] hosted by [Found][found].
Elasticsearch is powered by [Lucene][lucene] which is a powerful full-text indexing
library and server. There are separate clusters running for the lynr-co-stage and
lynr-co applications.

[es]: http://elasticsearch.org
[found]: https://www.found.no
[lucene]: https://lucene.apache.org
