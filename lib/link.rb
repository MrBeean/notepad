# encoding: utf-8
#
# Класс «Ссылка», разновидность базового класса «Запись»
class Link < Post
  def initialize
    super

    @url = ''
  end

  def read_from_console
    puts 'Адрес ссылки (url):'
    @url = STDIN.gets.chomp

    puts 'Что за ссылка?'
    @text = STDIN.gets.chomp
  end

  # Метод to_string для ссылки возвращает массив из трех строк: адрес ссылки,
  # описание ссылки и строка с датой создания ссылки.
  def to_strings
    time_string = "Создано: #{@created_at.strftime('%Y.%m.%d, %H:%M:%S')} \n\r"

    [@url, @text, time_string]
  end

  def to_db_hash
    # Вызываем родительский метод to_db_hash ключевым словом super. К хэшу,
    # который он вернул добавляем специфичные для этого класса поля методом
    # Hash#merge
    super.merge('text' => @text, 'url' => @url)
  end
end
