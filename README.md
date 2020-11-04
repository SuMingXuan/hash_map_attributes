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
  include HashMapAttributes
  hash_map_attributes :image_url, to: :extra_data
  hash_map_attributes :background_url, prefix: :content, to: :extra_data

end

page = Page.new(image_url: 'http://www.image.com/example1.png', content_background_url: 'http://www.image.com/example2.png')
page.save
page.image_url #=> http://www.image.com/example1.png
page.content_background_url #=> http://www.image.com/example2.png
```
### 查询

如果是 jsonb 的话，那么则支持查询
```ruby
Page.where_hash(image_url: 'http://www.baidu.com', content_background_url: 'http://www.baklib.com')
```
控制台会打印如下查询语句

```sql 
SELECT "pages".* FROM "pages" WHERE (special_channels.extra_data->>'image_url' = 'http://www.baidu.com' and special_channels.extra_data->>'background_url' = 'http://www.baklib.com')
```
