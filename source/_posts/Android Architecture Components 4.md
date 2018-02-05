---
title: Android Architecture Components 详解(四)Room Persistence Library
date: 2017-08-16 15:57:19
tags: 
- Architecture
- 翻译
categories:
- Android

---
Room在SQLite上提供了一个抽象层，以便流畅地使用SQLite的全部功能进行数据库访问。
[英文原文地址](https://developer.android.com/topic/libraries/architecture/room.html)科学上网

>注意：要将 Room 导入到您的Android项目中，请参阅[adding components to your project](http://www.codepeng.cn/2017/08/10/Android%20Architecture%20Components%200/)

持久化数据可以让处理大量的结构化数据的应用受益匪浅。最常见的例子是缓存数据。这样当设备没有网络的时候用户依然可以访问数据。在设备重新连接到网络时，用户操作的数据可以同步到服务器。

framework本身提供了对SQL操作的支持。虽然这些API非常强大，但是它们相对低级而且操作起来会花费大量的时间和精力：

- 没有对原始SQL查询的编译时验证。 随着数据图的更改，需要手动更新受影响的SQL查询。 这个过程可能是耗时且容易出错的。
- 需要使用大量样板代码来在SQL查询和Java数据对象之间进行转换。

Room在提供SQLite抽象层的时候考虑到了这些问题。

<!-- more -->

Room有3个主要的组成部分：

- **Database：**可以使用此组件创建数据库持有者。 注释定义实体列表，类的内容定义数据库中数据访问对象(DAO)的列表。 它也是底层连接的主要接入点。

	注释类应该是一个扩展RoomDatabase的抽象类。 在运行时，您可以通过调用Room.databaseBuilder()或Room.inMemoryDatabaseBuilder()获取一个实例。
	
- **Entity:**该组件表示一个保存数据库行的类。 对于每个实体，创建一个数据库表来保存。 您必须通过Database类中的entities数组引用实体类。实体的每个字段都保存在数据库中，除非您使用@Ignore注释它。

>**注意：**实体可以有一个空构造函数（如果DAO类可以访问每个持久化字段），或者一个构造函数的参数包含与实体中的字段匹配的类型和名称。 Room还可以使用全部或部分构造函数，例如只接收一些字段的构造函数。

- **DAO：**该组件表示作为数据访问对象（DAO）的类或接口。 DAO是Room的主要组件，负责定义访问数据库的方法。 用@Database注释的类必须包含一个具有0个参数的抽象方法，并返回使用@Dao注释的类。 在编译时生成代码时，Room创建一个这个类的实现。

>**注意**：通过使用DAO类代替查询生成器或直接查询访问数据库，可以分开你的数据库架构的不同组件。 此外，DAO允许您在测试应用程序时轻松地模拟数据库访问。

这些组件及其与应用部分的关系如图1所示：

![图1.Room结构图](https://developer.android.com/images/topic/libraries/architecture/room_architecture.png)

以下代码片段包含具有1个实体和1个DAO的示例数据库配置：

User.java

``` java
@Entity
public class User {
    @PrimaryKey
    private int uid;

    @ColumnInfo(name = "first_name")
    private String firstName;

    @ColumnInfo(name = "last_name")
    private String lastName;

    // Getters and setters are ignored for brevity,
    // but they're required for Room to work.
}
```

UserDao.java

``` java
@Dao
public interface UserDao {
    @Query("SELECT * FROM user")
    List<User> getAll();

    @Query("SELECT * FROM user WHERE uid IN (:userIds)")
    List<User> loadAllByIds(int[] userIds);

    @Query("SELECT * FROM user WHERE first_name LIKE :first AND "
           + "last_name LIKE :last LIMIT 1")
    User findByName(String first, String last);

    @Insert
    void insertAll(User... users);

    @Delete
    void delete(User user);
}

```

AppDatabase.java

``` java
@Database(entities = {User.class}, version = 1)
public abstract class AppDatabase extends RoomDatabase {
    public abstract UserDao userDao();
}

```

创建上述文件后，使用以下代码获取创建的数据库的实例：

``` java
AppDatabase db = Room.databaseBuilder(getApplicationContext(),
        AppDatabase.class, "database-name").build();
```

>**注意：**在实例化AppDatabase对象时，应遵循单例设计模式，因为每个RoomDatabase实例都相当昂贵，并且您很少需要访问多个实例。


## Entities
当类被@Entity注释并且在@Database注释的entities属性中引用时，Room会在数据库中为该实体创建一个数据库表。

默认情况下，Room为实体中定义的每个字段创建一个列。 如果一个实体具有不想持久化的字段，可以使用@Ignore对它们进行注释，如下面的代码片段所示：

``` java
@Entity
class User {
    @PrimaryKey
    public int id;

    public String firstName;
    public String lastName;

    @Ignore
    Bitmap picture;
}
```

要持久化一个字段，Room必须可以访问它。你可以定义这个字段为public，或者提供getter和setter方法。如果使用setter和getter方法，请记住，它们基于Room中的Java Bean约定。

## Primary key
每个实体必须至少定义1个字段作为主键。 即使只有1个字段，您仍然需要使用@PrimaryKey注释来注释该字段。 另外，如果您希望Room实体自增长ID，您可以设置@PrimaryKey的autoGenerate属性。 如果实体具有复合主键，则可以使用@Entity注释的primaryKeys属性，如以下代码片段所示：

``` java
@Entity(primaryKeys = {"firstName", "lastName"})
class User {
    public String firstName;
    public String lastName;

    @Ignore
    Bitmap picture;
}

```

默认情况下，Room使用类名作为数据库表名。 如果希望表具有不同的名称，请设置@Entity注释的tableName属性，如以下代码片段所示：

``` java
@Entity(tableName = "users")
class User {
    ...
}

```

>**注意：**SQLite中的表名不区分大小写。

与tablename属性类似，Room使用字段名作为数据库中的列名。 如果您希望列具有不同的名称，请将@ColumnInfo注释添加到字段中，如以下代码片段所示：

``` java
@Entity(tableName = "users")
class User {
    @PrimaryKey
    public int id;

    @ColumnInfo(name = "first_name")
    public String firstName;

    @ColumnInfo(name = "last_name")
    public String lastName;

    @Ignore
    Bitmap picture;
}

```

## Indices and uniqueness

根据访问数据的方式，您可能希望对数据库中的某些字段添加索引，以加快查询速度。 要向实体添加索引，请在@Entity注释中包含indexes属性，列出要包含在索引或组合索引中的列的名称。 以下代码片段演示了此注释过程：

``` java
@Entity(indices = {@Index("name"),
        @Index(value = {"last_name", "address"})})
class User {
    @PrimaryKey
    public int id;

    public String firstName;
    public String address;

    @ColumnInfo(name = "last_name")
    public String lastName;

    @Ignore
    Bitmap picture;
}

```

有时，数据库中的某些字段或字段组必须是唯一的。 您可以通过将@Index注释的唯一属性设置为true来强制执行此唯一性属性。 以下代码示例可防止表具有包含firstName和lastName列的相同值集合的两行：

``` java
@Entity(indices = {@Index(value = {"first_name", "last_name"},
        unique = true)})
class User {
    @PrimaryKey
    public int id;

    @ColumnInfo(name = "first_name")
    public String firstName;

    @ColumnInfo(name = "last_name")
    public String lastName;

    @Ignore
    Bitmap picture;
}

```

## Relationships
因为SQLite是一个关系数据库，您可以指定对象之间的关系。 即使大多数ORM库允许实体对象相互引用，但是Room明确禁止此操作。 有关更多详细信息，请参阅附录：实体之间没有对象引用。

即使您不能使用直接关系，Room仍允许您在实体之间定义Foreign Key约束。

例如，如果有另一个名为Book的实体，您可以使用@ForeignKey注释来定义与User实体的关系，如以下代码片段所示：

``` java
@Entity(foreignKeys = @ForeignKey(entity = User.class,
                                  parentColumns = "id",
                                  childColumns = "user_id"))
class Book {
    @PrimaryKey
    public int bookId;

    public String title;

    @ColumnInfo(name = "user_id")
    public int userId;
}

```

外键非常强大，允许指定引用实体更新时发生的情况。 例如，如果通过在@ForeignKey注释中包含onDelete = CASCADE来删除用户的相应实例，则可以让SQLite删除用户的所有图书。

>注意：SQLite处理@Insert（OnConflict = REPLACE）用一组REMOVE和REPLACE操作代替单个UPDATE操作。 这种替换冲突值的方法可能会影响外键约束。 有关更多详细信息，请参阅ON_CONFLICT的[SQLite文档](https://sqlite.org/lang_conflict.html)。

## Nested objects
