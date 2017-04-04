# encoding: utf-8
#
# Подключим встроенный в руби класс Date для работы с датами
require 'date'

# Класс «Задача», разновидность базового класса «Запись»
class Task < Post
  def initialize
    super

    @due_date = Time.now
  end

  def read_from_console
    puts 'Что надо сделать?'
    @text = STDIN.gets.chomp

    puts 'К какому числу? Укажите дату в формате ДД.ММ.ГГГГ, ' \
      'например 12.05.2003'
    input = STDIN.gets.chomp
    @due_date = Date.parse(input)
  end

  def to_strings
    deadline = "Крайний срок: #{@due_date.strftime('%Y.%m.%d')}"
    time_string = "Создано: #{@created_at.strftime('%Y.%m.%d, %H:%M:%S')} \n\r"

    [deadline, @text, time_string]
  end

  def to_db_hash
    # Вызываем родительский метод to_db_hash ключевым словом super. К хэшу,
    # который он вернул добавляем специфичные для этого класса поля методом
    # Hash#merge
    super.merge('text' => @text, 'due_date' => @due_date.to_s)
  end
end
