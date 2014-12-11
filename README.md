jekyll-pagination-task
======================

An advanced pagination tool for jekyll

# Installation

First you must install jekyll-pagination-task. It can be done by 

~~~
gem install jekyll-pagination-task
~~~

or download the source code and compile it locally:

~~~
git clone https://github.com/emiapwil/jekyll-pagination-task
cd jekyll-pagination-task
gem build jekyll-pagination-task.gemsepc
gem install jekyll-pagination-task-{VERSION}.gem
~~~

Of course, you can just download the code and put
`lib/jekyll-pagination-task/pagination_task.rb` to the `_plugins/` folder of
your jekyll site.

# Configuration

After the installation you can put the following line in the `_plugins/ext.rb`
to make jekyll aware of its presence. If the ruby source file is put in
`_plugins`, however, you can skip this step.

~~~
require "jekyll-pagination-task"
~~~

Then it is also required to add the following lines in `_config.yml`:

~~~
pagination_task:
  page_per_pager: 7
  format: /:dir/:name/:Num
  filter_class: Jekyll::PaginationTask::DefaultPaginationFilter
~~~

The first line is crucial since it indicates that jekyll-pagination-task plugin
will be enabled. The other three lines are all optional:

- `page_per_pager`: how many pages should be include in one pager. The default
  value is 7.
- `format`: how the url of the generated pagers should look like. The default
  value is `/:dir/:name/:Num`. There are currently 4 macros:
  - `:dir`: it will be replaced by the path to the *template* page;
  - `:name`: it will be replaced by the basename of the *template* page;
  - `:num`: it will be replaced by the index of the generated page;
  - `:Num`: same as `:num` expect that 1 is replaced by an empty string.
- `filter_class`: which class to use as the filter for pages. The default value
  is Jekyll::PaginationTask::DefaultPaginationFilter.
