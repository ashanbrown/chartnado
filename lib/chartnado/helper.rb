require 'active_support/core_ext'

module Chartnado::Helper
  def chartnado_eval(&block)
    Chartnado.with_chartnado_dsl(&block)
  end
end
