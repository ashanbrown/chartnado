require 'spec_helper'

describe Chartnado do
  it "provides a dsl for vector operations" do
    expect(Chartnado.with_chartnado_dsl { {a: 2} / 2 }).to eq({a: 1})
  end
end
