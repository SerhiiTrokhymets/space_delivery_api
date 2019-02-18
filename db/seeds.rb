burgers    = ['Черный бургер', 'Романтический бургер']
salats     = ['Цезарь', 'Домашний']
categories = ['Бургеры', 'Салаты']

categories.each { |title| Category.create(title: title) }

burgers.each do |title|
  Product.create(title: title,
                 price: rand(90..120),
                 description: 'Пожалуй, вкуснее бургера вы не кушали',
                 weight: 390,
                 category_id: 1)
end

salats.each do |title|
  Product.create(title: title,
                 price: rand(90..120),
                 description: 'Самый свежий салат',
                 weight: 10,
                 category_id: 2)
end
