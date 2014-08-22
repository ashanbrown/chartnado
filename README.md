# Chartnado [![Gem Version](https://badge.fury.io/rb/chartnado.svg)](http://badge.fury.io/rb/chartnado)&nbsp;[![Travis CI Status](https://travis-ci.org/dontfidget/chartnado.png?branch=master)](https://travis-ci.org/dontfidget/chartnado)&nbsp;[![Code Climate](https://codeclimate.com/github/dontfidget/chartnado.png)](https://codeclimate.com/github/dontfidget/chartnado)&nbsp;[![Code Climate](https://codeclimate.com/github/dontfidget/chartnado/coverage.png)](https://codeclimate.com/github/dontfidget/chartnado)&nbsp;[![Dependency Status](https://gemnasium.com/dontfidget/chartnado.svg)](https://gemnasium.com/dontfidget/chartnado)

## Usage

Chartnado layers on top of [`chartkick`](http://ankane.github.io/chartkick/) and [`chartkick-remote`](http://github.com/dontfidget/chartkick-remote) allowing basic vector-style operations directly on to make it easy to feed them into charts.

In your controller, add the following to tell the controller to respond to json requests for chart data:

```ruby
include Chartnado
```

Then in your views, now in your views, you can write an expression to show the average tasks completed per today relative to total tasks:

```ruby
<%= line_chart { Task.group_by_day(:completed_at).count / Task.count } %>
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

where *block* calls the aggregating function you want applied to scope and *optional_label_block* is passed each key and data, so you can change the key (and even the data if you like).  The result for hash entries with matching keys is summed. 

To include these, just add:

`include Chartnado::GroupBy`


### Wrapping the chart renderer

You can wrap the render method in your controller.

```ruby
chartnado_wrapper :custom_renderer

def custom_renderer(*args, **options, &block)
  title = options[:title]
  render 'my-view', title: title, &block
end

```
