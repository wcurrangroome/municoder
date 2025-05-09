% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/municode_endpoints.R
\name{get_codes_toc}
\alias{get_codes_toc}
\title{Get the Table of Contents for an ordinance}
\usage{
get_codes_toc(job_id, product_id)
}
\arguments{
\item{job_id}{A unique identifier for a job}

\item{product_id}{A unique identifier for a product}
}
\value{
A dataframe with TOC sections and associated metadata
}
\description{
Corresponds to, for example: https://api.municode.com/codesToc?jobId=426172&productId=12429
}
\examples{
result = get_codes_toc(job_id = 426172, product_id = 12429)
}
