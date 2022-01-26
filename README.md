# Jack and Jill Memory Test (JAJ)

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.1415363.svg)](https://doi.org/10.5281/zenodo.1415363)

The JAJ is an adaptive test for visual working memory.

[Try a demo here.](https://shiny.gold-msi.org/longgold_demo/?test=JAJ)

## Citation

We also advise mentioning the software versions you used,
in particular the versions of the `JAJ`, `psychTestR`, and `psychTestRCAT` packages.
You can find these version numbers from R by running the following commands:

``` r
library(JAJ)
library(psychTestR)
library(psychTestRCAT)
if (!require(devtools)) install.packages("devtools")
x <- devtools::session_info()
x$packages[x$packages$package %in% c("JAJ", "psychTestR", "psychTestRCAT"), ]
```

## Acknowledgments

We like to thank  the members of the Applied Cognitive Psychology and Neuroscience Laboratory of the Sirius University of Science and Technology, Sochi for their support in developing this test.
 
## Installation instructions (local use)

1. If you don't have R installed, install it from here: https://cloud.r-project.org/

2. Open R.

3. Install the ‘devtools’ package with the following command:

`install.packages('devtools')`

4. Install the JAJ:

`devtools::install_github('klausfrieler/JAJ')`

## Usage

### Quick demo 

You can demo the JAJ at the R console, as follows:

``` r
# Load the JAJ package
library(JAJ)

# Run a demo test, with feedback as you progress through the test,
# and not saving your data
JAJ_demo()

# Run a demo test, skipping the training phase, and only asking 5 questions, as well a changinge the language
JAJ_demo(num_items = 5, take_training = FALSE, language = "DE")
```

### Testing a participant

The `JAJ_standalone()` function is designed for real data collection.
In particular, the participant doesn't receive feedback during this version.

``` r
# Load the JAJ package
library(JAJ)

# Run the test as if for a participant, using default settings,
# saving data, and with a custom admin password
JAJ_standalone(admin_password = "put-your-password-here")
```

You will need to enter a participant ID for each participant.
This will be stored along with their results.

Each time you test a new participant,
rerun the `JAJ_standalone()` function,
and a new participation session will begin.

You can retrieve your data by starting up a participation session,
entering the admin panel using your admin password,
and downloading your data.
For more details on the psychTestR interface, 
see http://psychtestr.com/.

The JAJ currently supports English (EN),  German (DE), and Russian (RU).
You can select one of these languages by passing a language code as 
an argument to `JAJ_standalone()`, e.g. `JAJ_standalone(languages = "DE")`,
or alternatively by passing it as a URL parameter to the test browser,
eg. http://127.0.0.1:4412/?language=DE (note that the `p_id` argument must be empty).

## Installation instructions (Shiny Server)

1. Complete the installation instructions described under 'Local use'.
2. If not already installed, install Shiny Server Open Source:
https://www.rstudio.com/products/shiny/download-server/
3. Navigate to the Shiny Server app directory.

`cd /srv/shiny-server`

4. Make a folder to contain your new Shiny app.
The name of this folder will correspond to the URL.

`sudo mkdir JAJ`

5. Make a text file in this folder called `app.R`
specifying the R code to run the app.

- To open the text editor: `sudo nano JAJ/app.R`
- Write the following in the text file:

``` r
library(JAJ)
JAJ_standalone(admin_password = "put-your-password-here")
```

- Save the file (CTRL-O).

6. Change the permissions of your app directory so that `psychTestR`
can write its temporary files there.

`sudo chown -R shiny JAJ`

where `shiny` is the username for the Shiny process user
(this is the usual default).

7. Navigate to your new shiny app, with a URL that looks like this:
`http://my-web-page.org:3838/JAJ

## Implementation notes

By default, the JAJ implementation always estimates participant abilities
using weighted-likelihood estimation.
We adopt weighted-likelihood estimation for this release 
because this technique makes fewer assumptions about the participant group being tested.
This makes the test better suited to testing with diverse participant groups
(e.g. children, clinical populations).



## Usage notes

- The JAJ runs in your web browser.
- By default, image files are hosted online on our servers.
The test therefore requires internet connectivity.

## References:

D. Müllensiefen, K. Frieler, S. Silas, E.  Tsigeman, M.  Likhanov, Y. Kovas (submitted). *Jack and Jill: construction, calibration and validation of an adaptive visuospatial working memory test*
 
