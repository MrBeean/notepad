if Gem.win_platform?
  Encoding.default_external = Encoding.find(Encoding.locale_charmap)
  Encoding.default_internal = __ENCODING__

  [STDIN, STDOUT].each do |io|
    io.set_encoding(Encoding.default_external, Encoding.default_internal)
  end
end

# Подключаем класс Post и его детей: Memo, Link, Task
require_relative 'lib/post'
require_relative 'lib/memo'
require_relative 'lib/link'
require_relative 'lib/task'

# Поздороваемся с пользователем и просим у него, что он хочет создать.

puts 'Привет, я твой блокнот! +SQLite'
puts
puts 'Что хотите записать в блокнот?'

# Запишем в переменную choices массив типов записей, которые можно создать,
# вызвав у класса Post метод post_types (статический метод).

choices = Post.post_types.keys

choice = -1
until choice >= 0 && choice < choices.size
  choices.each_with_index do |type, index|
    puts "\t#{index}. #{type}"
  end
  choice = gets.to_i
end

# Как только выбор сделан, мы можем создать запись нужного типа, передав выбор
# строку с название класса в статический метод create класса Post.
entry = Post.create(choices[choice])

entry.read_from_console

# Сохраняем пост в базу данных
rowid = entry.save_to_db

puts "Запись сохранена в базе, id = #{rowid}"
