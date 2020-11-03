# HashMapAttributes

将你json类型的字段映射为字段去操作

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hash_map_attributes'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install hash_map_attributes

## Usage
```ruby
class Page < ApplicationRecord
    # == Schema Information
    #
    # Table name: special_channels
    #
    #  id          :bigint           not null, primary key
    #  description :string
    #  title       :string
    #  extra_data  :jsonb
    #  created_at  :datetime         not null
    #  updated_at  :datetime         not null
  hash_map_attributes :image_url, :background_url, to: :extra_data
end

page = Page.new(image_url: 'http://www.image.com/example1.png', background_url: 'http://www.image.com/example2.png')
page.save
page.image_url #=> http://www.image.com/example1.png
page.background_url #=> http://www.image.com/example2.png
```

