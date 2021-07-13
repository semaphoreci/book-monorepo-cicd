\newpage

© 2021 Rendered Text. All rights reserved.

This work is licensed under Creative Commmons
Attribution-NonCommercial-NoDerivatives 4.0 International.
To view a copy of this license, visit
<https://creativecommons.org/licenses/by-nc-nd/4.0>

This book is open source: TODO: link
<https://github.com/semaphoreci/book-cicd-docker-kubernetes>

Published on the Semaphore website:
[https://semaphoreci.com](https://semaphoreci.com/?utm_source=ebook&utm_medium=pdf&utm_campaign=cicd-docker-kubernetes-semaphore)

$MONTHYEAR: First edition v1.0 (revision $REVISION)

\newpage

Share this book:

> _I've just started reading "CI/CD for Monorepos", a free ebook by @semaphoreci: TODO:link https://bit.ly/3bJELLQ ([Tweet this!](TODO: link https://ctt.ac/c5Ub9))_

\newpage

## Preface

The term *monorepo*, as such, began appearing around 2014. Wikipedia had its first dedicated page in 2018. Yet, monorepos have been around a lot longer than that. One of oldest, still active repositories is the [BRL-CAD](https://sourceforge.net/p/brlcad/code/HEAD/tree/) project, a open-source CAD software developed by the Balistic Research Laboratory in the US Army, which dates back to 1983 and has all the markings of a small-scale monorepo: the main application, its web version, a work-in-progress UI revamp, build tools and shared libraries. The term monorepo may be young but the concept is definetly not.

The take here is that we didn't use to need a special world for these kinds of repos. Developers applied their best judgment to decide where code should go. Software development, inevitably, gets more complex, and with time two paradigms crystallized: the monorepo and the multirepos. 

At first, helped in part by the popularity of microservices and a divide-and-conquer mindset, it seemed that multi-repos would win out. Monorepos, however, always kept a loyal following that praised their benefits. 

Many big companies open-sourced their smart build systems, tooling evolved and new solutions were developed. In 2020 the [term monorepo peaked](https://trends.google.com/trends/explore?date=all&q=monorepo,multirepo,multi-repo,mono-repo), showing that monorepos are getting a lot of attention and traction. The jury is still out, but the tide seems to be turning.

At Semaphore, we have been using monorepos internally for a long time. We know how cool they can be and how painful they can get to set up.

> Monorepos offer many benefits for engineering teams, but until now, setting one up was needlessly traumatic. Since we use a monorepo ourselves, we understood the pain of setting up a functional CI/CD pipeline.  It goes without saying that we were very motivated in making the experience of configuring such a project on Semaphore a seamless process.
>
> ​	Damjan Becirovic, Software Engineer at Semaphore

Because, we want every engineering team to enjoy a great experience, [we’ve released monorepo features](https://semaphoreci.com/blog/monorepo-support-available). Bringing Semaphore to be the first CI/CD platform with such support.

We’re not done. The UI improvements, the enhanced stability and scalability, and the `change_in` function is only the beginnning.  We’re still working on new features and bringing the monorepo experience to the 21st century. This book is part of this effort. We want to help pave the way into a future where scaling up a monorepo is as easy as the cloud has made it to scale up an online product.

\newpage

## Who Is This Book For, and What Does It Cover?

This book is intended for engineering teams, developers, and companies interested in trying out the monorepo way of software development. Teams already using this pattern in some form should also benefit greatly, as we’ll show a few ways of setting up monorepo-optimized CI/CD pipelines. By reading this book and adopting the practices laid out here, you can speed up your build times many-fold.

We hope that CTOs and other people in charge of delivering software projects will gain some insight into deciding if monorepos are the way forward for their companies. By showing what it takes to build monorepo-first CI/CD pipeline. How to save money, and time, and speed up software development using the techniques laid out here.

Developers, by understanding the big picture, should see that monorepos are not good or evil, just a different way of working. You will also find working code and configuration that you can reuse in your projects.

Chapter 1, "What is a Monorepo", introduces the basics, relates stories about how other companies have successfully migrated to a monorepo. The challenges and benefits. This chapter will help you decide is monorepo is the right way for you.

Chapter 2, "Continuous Integration", explains what you need to know about setting up a CI pipeline that builds and tests only the code that changed.

Chapter 3, "Continuous Deployment", describes how to expand the CI pipeline with continuous deployments. We’ll learn how to take a working example and deploy it on a real cloud service. At the end of the book, you’ll have a working microservice application build, tested and deployed from a monorepo.

## How to Contact Us

We would very much love to hear your feedback after reading this book. What did you like and learn? What could be improved? Is there something we could explain further?

A benefit of publishing an ebook is that we can continuously improve it. And that's exactly what we intend to do based on your feedback.

You can send us feedback by sending an email to <learn@semaphoreci.com>.

Find us on Twitter: <https://twitter.com/semaphoreci>

Find us on Facebook: <https://facebook.com/SemaphoreCI>

Find us on LinkedIn: <https://www.linkedin.com/company/rendered-text>

## About the Author

**Pablo Tomas Fernandez Zavalia** is an electronic engineer and writer. He started his career in developing for the City of Buenos Aires City Hall (buenosaires.gob.ar). After graduating, he joined British Telecom as head of the Web Services department in Argentina. He then worked on IBM as a database administrator, where he also did tutoring, DevOps, and cloud migrations. In his free time he enjoys writing, sailing and board games. Follow Tomas on Twitter at [\@tomfernblog](https://twitter.com/tomfernblog).

## Acknowledments

I want to thank Marko Anastasov for the chance to write this book.
In addition, all the Semaphore engineering team and marketing teams. Without their help, this book could never have existed.
