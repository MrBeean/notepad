# Подключаем гем для общения с базой данных sqlite3
require 'sqlite3'

class Post

  SQLITE_DB_FILE = 'data/notepad.sqlite'.freeze

  # Теперь нам нужно будет читать объекты из базы данных поэтому удобнее всегда
  # иметь под рукой связь между классом и его именем в виде строки
  def self.post_types
    {'Memo' => Memo, 'Task' => Task, 'Link' => Link}
  end

  # Параметром для метоа create теперь является строковое имя нужного класса
  def self.create(type)
    post_types[type].new
  end

  def initialize
    @created_at = Time.now
    @text = []
  end

  def read_from_console
    # Этот метод должен быть реализован у каждого ребенка
  end

  def to_strings
    # Этот метод должен быть реализован у каждого ребенка
  end

  def save
    file = File.new(file_path, 'w:UTF-8') # открываем файл на запись

    to_strings.each { |string| file.puts(string) }

    file.close
  end

  def file_path
    current_path = File.dirname(__FILE__)

    file_time = @created_at.strftime('%Y-%m-%d_%H-%M-%S')

    "#{File.expand_path('..', current_path)}" + "/data/#{self.class.name}_#{file_time}.txt"
  end

  def save_to_db
    db = SQLite3::Database.open(SQLITE_DB_FILE)
    db.results_as_hash = true

    # Выполняем Запрос к базе на вставку новой записи в соответствии с хэшом,
    # сформированным методом to_db_hash.
    post_hash = to_db_hash

    db.execute(
      'INSERT INTO posts (' +
        post_hash.keys.join(', ') +
        ") VALUES (#{('?,' * post_hash.size).chomp(',')})",
      post_hash.values
    )

    # Сохраняем в переменную id записи, которую мы только что добавили в таблицу
    insert_row_id = db.last_insert_row_id

    # Закрываем соединение
    db.close

    # Возвращаем идентификатор записи в базе
    insert_row_id
  end

  def to_db_hash
    # Дочерние классы сами знают свое представление, но общие для всех детей
    # переменные экземпляра можно заполнить уже сейчас в родительском классе.
    {
      'type' => self.class.name,
      'created_at' => @created_at.to_s
    }
    # self — ключевое слово, указывает на «этот объект», то есть конкретный
    # экземпляр класса, где выполняется в данный момент этот код.
    #
    # Дочерние классы должны дополнять этот хэш массив своими полями
  end
end
