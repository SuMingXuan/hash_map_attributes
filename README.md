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
  hash_map_attributes :left, :right, to: :extra_data
end
```
### 创建或修改

```ruby
# 会根据 to 指定的字段添加对应的key
page = Page.create(left: nil)
page.save
page.extra_data #=> {"left"=>nil}

```

如果我们需要嵌套 hash, 需要使用 parent 参数指定上一层的键
```ruby
class Page < ApplicationRecord
  hash_map_attributes :logo, :title :cards, parent: :left
  hash_map_attributes :logo, :title :cards, parent: :right
end

# 也可以使用 update 去更新对应区域的值
page.right_logo = 'right_logo1'
page.extra_data #=> {"left"=>nil, "right"=>{"logo"=>"right_logo1"}}
```

多层嵌套
```ruby
class Page < ApplicationRecord
  # parent 指定的是上一层的自动连接起来的命名
  hash_map_attributes :card1, :card2, parent: :left_cards
  hash_map_attributes :card1, :card2, parent: :right_cards
end

page.left_cards_card1 = 'left_cards_card1'
page.extra_data #=> {"left"=>{"cards"=>{"card1"=>"left_cards_card1"}},"right"=>{"logo"=>"right_logo1"}}
```

### 查询

如果是 jsonb 的话，那么则支持查询
```ruby
Page.where_hash(left_cards_card1: 'left_cards_card1')
```
控制台会打印如下查询语句

```sql 
SELECT "special_channels".* FROM "special_channels" WHERE (special_channels.extra_data->'left'->'cards'->>'card1' = 'left_cards_card1')
```
