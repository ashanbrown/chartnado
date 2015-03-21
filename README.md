# Chartnado [![Gem Version](https://badge.fury.io/rb/chartnado.svg)](http://badge.fury.io/rb/chartnado)&nbsp;[![Travis CI Status](https://travis-ci.org/ashanbrown/chartnado.png?branch=master)](https://travis-ci.org/ashanbrown/chartnado)&nbsp;[![Code Climate](https://codeclimate.com/github/ashanbrown/chartnado.png)](https://codeclimate.com/github/ashanbrown/chartnado)&nbsp;[![Code Climate](https://codeclimate.com/github/ashanbrown/chartnado/coverage.png)](https://codeclimate.com/github/ashanbrown/chartnado)&nbsp;[![Dependency Status](https://gemnasium.com/ashanbrown/chartnado.svg)](https://gemnasium.com/ashanbrown/chartnado)[![Coverage Status](https://coveralls.io/repos/ashanbrown/chartnado/badge.png?branch=master)](https://coveralls.io/r/ashanbrown/chartnado?branch=master)

Chartnado layers on top of [`chartkick`](http://ankane.github.io/chartkick/) and [`chartkick-remote`](http://github.com/ashanbrown/chartkick-remote) allowing basic vector-style operations directly on to make it easy to feed them into charts.  It also provides some useful defaults and the ability to show totals on pie and stacked area charts when using google charts.

## Usage

In your controller, add the following to tell the controller to respond to json requests for chart data:

```ruby
include Chartnado
```

Then in your views, you can write an expression to show the average tasks completed per today relative to total tasks like this:

```ruby
<%= line_chart { Task.group_by_day(:completed_at).count / Task.count } %>
```

See the demo of chartkick-remote and Chartnado at http://chartkick-remote-demo.heroku.com.

## Totals

By default chartnado adds totals to pie and stacked area charts using some hacky settings for google charts.  To get the total to appear, you need to use the chartnado version of the chartkick javascript called `chartkick-chartnado.js` instead of `chartkick.js`.  If you are including the javascript in sprockets manifest file, this:

```
//= require chartkick
```

should be replaced by this:

```
//= require chartkick-chartnado
```

## Supported Vector Operations on Series

Chartnado supports the following operations on series/multiple-series data:

* Single/Multiple-Series * Scalar
* Single/Multiple-Series / Scalar
* Single/Multiple-Series / Single Series
* Single Series / Single Series
* Multiple-Series / Single Series
* Multiple-Series / Multiple Series
* Single/Multiple-Series + Scalar

A "Series" is a hash of values (i.e. `{ 2 => 4, 3 => 9 }`).  A "Multiple-Series" can either be specified in two ways:

1. With the series identifier as the first element in each array that forms the key, as in:
    ```ruby
        {['series a', 0] => 1}, ['series b', 0] => 2}
    ```

1. With the series identifier as the first element in an array of single series, as in:
    ```ruby
        [['series a', {0 => 1}], ['series b', {0 => 2}]]
    ```

All series in an operation must use the same format.

## Remote Requests

By default requests for data in blocks, will be fetched remotely, unless `remote: false` is passed as an option to *chartkick_remote*.  Using this methodology, it's easy to write a page that makes many, many json requests, which may swamp your server and possibly even time out if you have a global `timeout` value set for your ajax requests.  @maccman's jquery.ajax.queue.coffee script provides a basic queueing transport layer for ajax requests which I've modified to provide an option to set the maximum number of requests that can be made in parallel (see https://gist.github.com/ashanbrown/1ad9ab33971b64fe6fef).  This is provided as an asset as part of chartkick-remote and you can include it in your javascript manifest like this:

```
//= require jquery.ajax.queue-concurrent
```
  
Chartnado extends chartkick to accept an *ajaxOptions* hash, which can be passed via chartkick_remote, which means you can then specify the maximum number of allowable requests globally for your page as follows:

```
chartkick_remote ajaxOptions: {queue: true, queueMaxConcurrency: 2} 
```

## Chartnado::SeriesHelper

Chartnado also offers direct access to the helpers that implement the above operators.

* series_product
* series_ratio
* series_sum

To include these, just add:

`include Chartnado::Series`

### group_by

While you can use ActiveRequest::Query.group to group results, you may find it useful to (a) make the grouping the first key, and (b) aggregate/rename groups.  `group_by` provides this ability as follows:

```ruby
  group_by('owners.id', Task.group_by_day(:completed_at)) { count }
  
```

You can call it as: 

```ruby
group_by(<expression>, scope, optional_label_block, &eval_block)
```

where *block* calls the aggregating function you want applied to scope and *optional_label_block* is passed each key and data, so you can change the key (and even the data if you like).  The result for hash entries with identical keys is summed.  The label block is expected to return a 2-element array, where the first element is the key and the second element is the data.

To include these, just add:

`include Chartnado::GroupBy`

### Defining series 

It may be useful to define series/multiple-series inside your code so that it can be shared in multiple views.  Chartnado provides the `define_series` and `define_multiple_series` class methods to aid in adding shared series in your helpers.

```ruby
    # for a single series
    define_series(:my_series) { { 0 => 1 } / 2 }`
    
    # for multiple series
    define_multiple_series(
      my_first_series: -> { { 0 => 1 } / 2 }
      my_second_series: -> { { 0 => 1 } / 2 }
    )
```

To include these methods in a view helper, just add the following to the helper:

`include Chartnado::Helpers::SeriesHelpers

### Wrapping the chart renderer

You can wrap the chart rendering method in your controller if you want finer control over the rendering process, such as wrapping the chartkick output in a partial.  To do this, include something like the following in your controller:

```ruby
    chartnado_wrapper :custom_renderer
    
    def custom_renderer(*args, **options, &block)
      title = options[:title]
      render 'my-chart-partial', title: title, &block
    end
```
