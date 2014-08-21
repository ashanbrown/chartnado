# Chartnado [![Gem Version](https://badge.fury.io/rb/chartnado.svg)](http://badge.fury.io/rb/chartnado)&nbsp;[![Travis CI Status](https://travis-ci.org/dontfidget/chartnado.png?branch=master)](https://travis-ci.org/dontfidget/chartnado)&nbsp;[![Code Climate](https://codeclimate.com/github/dontfidget/chartnado.png)](https://codeclimate.com/github/dontfidget/chartnado)&nbsp;[![Code Climate](https://codeclimate.com/github/dontfidget/chartnado/coverage.png)](https://codeclimate.com/github/dontfidget/chartnado)&nbsp;[![Dependency Status](https://gemnasium.com/dontfidget/chartnado.svg)](https://gemnasium.com/dontfidget/chartnado)

## Usage

Chartnado allows basic vector-style operations directly on to make it easy to feed them into [`chartkick`](http://ankane.github.io/chartkick/) (and [`chartkick-remote`](http://github.com/dontfidget/chartkick-remote)).

In your controller, add the following to tell the controller to respond to json requests for chart data:

```ruby
include Chartnado
```

Then in your views, now in your views, you can write an expression to show the average tasks completed per today relative to total tasks:

```ruby
<%= line_chart chartnado_eval { Task.group_by_day(:completed_at).count / Task.count } %>
```

If you are using `chartkick-remote`, you can enable Chartnado evaluation on your block by default, by setting a config setting:

Chartkick::Remote.config.eval_block = lambda { |&block| Chartnado.chartnado_eval(&block) }  

## Supported Vector Operations on Series

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
        [['series a', {0 => 1}], ['series b' {0 => 2}]]
    ```

Both series in an operation must use the same format.

## Chartnado::SeriesHelper

Chartnado also offers direct access to the helpers that implement the above operators.

* series_product
* series_ratio
* series_ratio
* group_by

To include these, just add:

`include Chartnado::SeriesHelper`
