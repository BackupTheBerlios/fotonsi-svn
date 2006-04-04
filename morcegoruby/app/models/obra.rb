class Obra < ActiveRecord::Base
  has_many :promotors
  has_many :suelos
end
