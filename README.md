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

## Site Configuration

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
  post_only: true
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
- `post_only`: only paginate the posts, the default value is `true`. If set to
  `false`, the pages will be paginated as well.

## Page Configuration

Unlike [jekyll-paginate][jekyll-paginate], this plugin identify *template* pages
by checking whether the attribute `paginate` is set to `true` in a page. To make
things more flexible, some other optional attributes can be set as well. These
configurations are demonstrated in the following example:

[jekyll-paginate]: https://github.com/jekyll/jekyll-paginate

~~~
---
paginate: true
page_per_pager: 8
pagination_format: /posts/:Num
filter_class: Jekyll::PaginationTask::DefaultPaginationFilter
pagination_filter:
  - ['layout', 'is', 'post']
  - ['category', 'all', ['test', 'ruby']]
---
~~~

- `paginate`: indicates that this page is a *template*.
- `page_per_pager`: same as `page_per_pager` in `_config.yml`.
- `pagination_format`: same as `format` in `_config.yml`.
- `filter_class`: same as `filter_class` in `_config.yml`.
- `pagination_filter`: this is used to store parameters for
  `Jekyll::PaginationTask::DefaultPaginationFilter`, each element of it will
  have the form of `[$ATTR, $RELATION, $PARAMETER]`. Then attribute
  `$ATTR` of the *template* page will be checked against `$A_LIST_OF_VALUES` and
  the pages that satisfy all these conditions will be set as the pager's *posts*
  (this is for compatibility with jekyll-paginate). There are currently 8
  relations supported:
  - `all`: *true* if the attribute `$ATTR` contains all values from `$PARAMETER`
    and otherwise *false*;
  - `any`: *true* if the attribute `$ATTR` contains any of the values from
    `$PARAMETER` and otherwise *false*;
  - `only`: *true* if the attribute `$ATTR` contains values only from
    `$PARAMETER` and otherwise *false*;
  - `none`: *true* if the attribute `$ATTR` contains no values from
    `$PARAMETER` and otherwise *false*;
  - `is`: *true* if `$ATTR` equals `$PARAMETER` and *false* otherwise
  - `is_not`: *true* if `$ATTR` doesn't equal `$PARAMETER` and *false* otherwise
  - `in`: *true* if `$ATTR` is a member of `$PARAMETER`
  - `not_in`: *true* if `$ATTR` is not a member of `$PARAMETER` 

It is notable that the types of `$ATTR` and `$PARAMETER` are also indicated in
these relationships and I think they can cover most cases. If the default
filter still fails to meet the needs, you can always develop your own filter
class and point to it by setting the `filter_class` option.

# Demonstration

Assuming the full name of the *template* page is `demo/post.md` which selects 45
posts using the frontmatter above. The following files will be generated:
`/demo/post/index.html`, `/demo/post/2/index.html`, ..., and
`/demo/post/6/index.html`.

If we have another file named `demo/post7.md` which uses the same frontmatter
expect the `page_per_pager` line, it will use the configuration in `_config.yml`
and 7 pages will be generated with prefix `/demo/post7/` instead of
`/demo/post/`.

If we modify the `pagination_format` in this `demo/post7.md` file to
`/home/test/:Num`, then the pages will be generated in `/home/test/` folder
rather than `/demo/post7`.

# Work Flow

Here is a quick introduction to the implementation of jekyll-pagination-task:

- selects pages with `paginate` set to `true` as *templates*
- for each *tempalte*, construct the *filter* with *site* and the *template*
- selects pages that satisfies the filter
- create `PTPager`, which is derived from `Jekyll::Pager` and can set up the
  correct url for generated pagination pages. Then the generated `pager` pages
  are appended to site.pages

# Features not Supported yet

- Infinite `page_per_pager`.
- Structed options in the frontmatter.
- Customized *Sorter* support. Currently the posts are not sorted.

# BUGs

I'm new to Ruby and this package is not fully tested, so there might be many
bugs...

## Known Bugs

### **Unable to generate correct pages when the `url` function of the template has been called earlier**.
  
The reason is that Jekyll::Page will generate the url once `url` is called and
store it in `@url` which is not accessible thus not modifiable. One workaround
is to hack the Jekyll package and add the `:url` to `attr_accesssor` in
`Jekyll::Page` and then add one more line in `create_pager` just before it
returns:

~~~
instance.url = nil # reset the url
~~~
