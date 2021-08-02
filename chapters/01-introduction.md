\newpage

© 2021 Rendered Text. All rights reserved.

This work is licensed under Creative Commmons
Attribution-NonCommercial-NoDerivatives 4.0 International.
To view a copy of this license, visit
<https://creativecommons.org/licenses/by-nc-nd/4.0>

This book is open source: 
<https://github.com/semaphoreci/book-monorepo-cicd>

Published on the Semaphore website:
[https://semaphoreci.com](https://semaphoreci.com/?utm_source=ebook&utm_medium=pdf&utm_campaign=monorepo-cicd)

$MONTHYEAR: First edition v1.0 (revision $REVISION)

\newpage

Share this book:

> _ I’ve just started reading “CI/CD for Monorepos,” a free ebook by @semaphoreci: TODO:link https://bit.ly/3bJELLQ ([Tweet this!](TODO: link https://ctt.ac/c5Ub9))_

\newpage

## Preface

A monorepo is a new name for an old idea: place a bunch of software projects in the same code repository. Organizations that overcome technical challenges in adopting monorepos enjoy many benefits:

- Cultural: increased bandwidth of knowledge transfer and a higher level of collaboration among teams.
- Technical: common coding and tooling standards, simplified dependency management and configuration reuse.

Big companies like Google, Facebook, Twitter, and Airbnb have been using monorepos for years. Today, we see a growing number of smaller teams adopting monorepos as their way of coding. The jury is still out, but the tide seems to be turning.

Why the change now? On the frontend side, the proliferation of JavaScript-based tools has reached a state of the art in which it is possible to develop very complex applications in a single programming language. Architects of frontend projects now face the problems of separating concerns and avoiding code duplication — and have a good set of tools to solve them by working in a monorepo.

On the backend side, serverless and microservices-based architectures drive developers to logically isolate their code into small units. Most of these services are written with the same set of tools and coding standards. And they are built, configured, and deployed in the same way. Placing them in a monorepo is an efficient way of avoiding duplicate configurations and processes.

At Semaphore, we have heard about this trend from a growing number of teams and have solved the technical challenge of running effective CI/CD pipelines for monorepos.

Using traditional CI/CD tools in the monorepo context, developers essentially need to build, test, and deploy all services all the time. Using Semaphore, developers run dynamic CI/CD workflows that run the right pipelines at the right time. This gives product teams more time to focus on building the next great feature.

\newpage

## Who Is This Book For, and What Does It Cover?

This book is intended for software engineers who are either exploring the monorepo way of software development or looking to optimize CI/CD the process for their monorepo.

By showing what it takes to build a monorepo-first CI/CD pipeline that saves time and speeds up software development cycles, we hope that CTOs and other engineering leaders will gain some insight into deciding if monorepos are the way forward for their companies and teams.

Chapter 1, “What is a Monorepo,” introduces the basics and relates stories about other companies that have successfully migrated to a monorepo. This chapter will help you decide if monorepo is the right way for you.

Chapter 2, “Continuous Integration,” explains what you need to know about setting up a CI pipeline that builds and tests only the code that changes.

Chapter 3, “Continuous Deployment,” describes how to expand the CI pipeline with continuous deployments. We’ll learn how to take a working example and deploy it on a real cloud service. At the end of the book, you’ll have a functional microservice application build, tested, and deployed from a monorepo.

## How to Contact Us

We would very much love to hear your feedback after reading this book. What did you like and learn? What could be improved? Is there something we could explain further?

A benefit of publishing an ebook is that we can continuously improve it. And that’s exactly what we intend to do based on your feedback.

You can send us feedback by sending an email to <learn@semaphoreci.com>.

Find us on Twitter: <https://twitter.com/semaphoreci>

Find us on Facebook: <https://facebook.com/SemaphoreCI>

Find us on LinkedIn: <https://www.linkedin.com/company/rendered-text>

## About the Author

**Pablo Tomas Fernandez Zavalia** is an electronic engineer and writer. He started developing for the City of Buenos Aires City Hall (buenosaires.gob.ar). After graduating, he joined British Telecom as head of the Web Services department in Argentina. He then worked on IBM as a database administrator, where he also did tutoring, DevOps, and cloud migrations. In his free time, he enjoys writing, sailing, and board games. Follow Tomas on Twitter at [\@tomfernblog](https://twitter.com/tomfernblog).

## About the Editor

**Marko Anastasov** is a software engineer, author and entrepreneur. Marko co-founded Rendered Text, a software company behind the Semaphore CI/CD service. He worked on building and scaling Semaphore from an idea to a cloud-based platform used by some of the world's best engineering teams. Follow Marko on Twitter at [\@markoa](https://twitter.com/markoa).

