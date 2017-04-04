# Подключаем гем для общения с базой данных sqlite3
require 'sqlite3'
require 'date'

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

  # Метод класса find_by_id находит в базе запись по идентификатору
  def self.find_by_id(id)
    # Если id не передали, мы ничего не ищем, а возвращаем nil
    return if id.nil?

    # Если id передали, едем дальше
    db = SQLite3::Database.open(SQLITE_DB_FILE)
    db.results_as_hash = true
    result = db.execute('SELECT * FROM posts WHERE  rowid = ?', id)
    db.close

    # Если в результате запроса получили пустой массис, снова возвращаем nil
    return nil if result.empty?

    # Если результат не пуст, едем дальше
    result = result[0]

    # Создаем пост нужного типа, заполняем его данными и возвращаем
    post = create(result['type'])
    post.load_data(result)
    post
  end

  # Метод класса find_all возвращает массив записей из базы данных, который
  # можно например показать в виде таблицы на экране.
  def self.find_all(limit, type)
    db = SQLite3::Database.open(SQLITE_DB_FILE)

    db.results_as_hash = false

    query = 'SELECT rowid, * FROM posts '
    query += 'WHERE type = :type ' unless type.nil?
    query += 'ORDER by rowid DESC '
    query += 'LIMIT :limit ' unless limit.nil?

    statement = db.prepare query

    statement.bind_param('type', type) unless type.nil?
    statement.bind_param('limit', limit) unless limit.nil?

    result = statement.execute!

    statement.close
    db.close

    result
  end

  # Метод load_data заполняет переменные эземпляра из полученного хэша
  def load_data(data_hash)
    # Общее для всех детей класса Post поведение описано в методе экземпляра
    # класса Post.
    @created_at = Time.parse(data_hash['created_at'])
    @text = data_hash['text']
    # Остальные специфичные переменные должны заполнить дочерние классы в своих
    # версиях класса load_data (вызвав текущий метод с пом. super)
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
