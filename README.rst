==============
ORM Benchmarks (2024 update)
==============

**Fork of `Tortoise's orm-benchmark <https://github.com/tortoise/orm-benchmarks>`_**

**Qualification criteria is:**

* Needs to support minimum 2 databases, e.g. sqlite + something-else
* Runs on Python3.12
* Actively developed
* Has ability to generate initial DDL off specified models
* Handle one-to-many relationships


Benchmarks:
===========

These benchmarks are not meant to be used as a direct comparison.
They suffer from co-operative back-off, and is a lot simpler than common real-world scenarios.

Tests:
------

A. Insert: Single (single entry at a time)
B. Insert: Batch (many batched in a transaction)
C. Insert: Bulk (using bulk insert operations)
D. Filter: Large (a large result set)
E. Filter: Small (a limit 20 with random offset)
F. Get
G. Filter: dict
H. Filter: tuple
I. Update: Whole (update the whole object)
J. Update: Partial (update only a single field of the whole object)
K. Delete


1) Small table, no relations
----------------------------

.. code::

    model Journal:
        id: autonumber primary key
        timestamp: datetime → now()
        level: small int(enum) → 10/20/30/40/50 (indexed)
        text: varchar(255) → A selection of text (indexed)


2) Small table, with relations
------------------------------

.. code::

    model Journal:
        id: autonumber primary key
        timestamp: datetime → now()
        level: small int(enum) → 10/20/30/40/50 (indexed)
        text: varchar(255) → A selection of text (indexed)

        parent: FK to parent BigTree
        child: reverse-FB to parent BigTree
        knows: M2M to BigTree


3) Large table
--------------

.. code::

    model BigTree:
        id: uuid primary key
        created_at: datetime → initial-now()
        updated_at: datetime → always-now()
        level: small int(enum) → 10/20/30/40/50 (indexed)
        text: varchar(255) → A selection of text (indexed)

        # Repeated 2 times with defaults, another 2 times as optional:
        col_float: double
        col_smallint: small integer
        col_int: integer
        col_bigint: big integer
        col_char: char(255)
        col_text: text
        col_decimal: decimal(12,8)
        col_json: json


ORMs:
=====

Django:
        https://www.djangoproject.com/

        Pros:

        * Provides all the essential features
        * Simple, clean, API
        * Great test framework
        * Excellent documentation
        * Migrations done right™

        Cons:

        * Brings whole Django along with it

peewee:
        https://github.com/coleifer/peewee


Pony ORM:
        https://github.com/ponyorm/pony

        Pros:

        * Fast
        * Does cacheing automatically

        Cons:

        * Does not support bulk insert.

SQLAlchemy ORM:
        http://www.sqlalchemy.org/

        Pros:

        * The "de facto" ORM in the python world
        * Supports just about every feature and edge case
        * Documentation re DB quirks is excellent

        Cons:

        * Complicated, layers upon layers of leaky abstractions
        * You have to manage transactions manually
        * You have to write a script to get DDL SQL
        * Documentation expects you to be intimate with SQLAlchemy
        * Migrations are add ons

SQLObject:
        https://github.com/sqlobject/sqlobject

        * Does not support 16-bit integer for ``level``, used 32-bit instead.
        * Does not support bulk insert.

Tortoise ORM:
        https://github.com/tortoise/tortoise-orm

        * Currently the only ``async`` ORM as part of this suite.
        * Disclaimer: I'm an active contributor to this project


Results (PostgreSQL)
====================

Python 3.12.7, Iterations: 100, DBtype: postgres

=============== ========== ========== ========== ============== ============ ========== ==========
Test 1          Django     peewee     Pony ORM   SQLAlchemy ORM Tortoise ORM Max        Best ORM
=============== ========== ========== ========== ============== ============ ========== ==========
Insert: Single      563.80     536.55    1500.67         962.60      2761.99    2761.99 Tortoise ORM
Insert: Batch       799.57     698.70    3145.00        4068.03      5003.34    5003.34 Tortoise ORM
Insert: Bulk       2346.33    2867.04          —        5468.10     12234.36   12234.36 Tortoise ORM
Filter: Large     53599.96   15496.01   92453.77       44642.89     29394.52   92453.77   Pony ORM
Filter: Small     16712.90    5894.77    9864.91       12226.83     15193.68   16712.90     Django
Get                1466.86     605.60    4337.04        1551.41      1932.19    4337.04   Pony ORM
Filter: dict      67822.90   21849.58   70717.73       42045.49     49947.06   70717.73   Pony ORM
Filter: tuple     70565.64   22813.15   94459.92       59525.48     45628.12   94459.92   Pony ORM
Update: Whole      1807.07    2274.08    4068.15        3976.72      6224.24    6224.24 Tortoise ORM
Update: Partial    2150.19    2838.52    4896.68        5453.64      8050.22    8050.22 Tortoise ORM
Delete             2379.63    4337.72    6352.98        6707.42      9086.45    9086.45 Tortoise ORM
Geometric Mean     5106.02    3452.16   10466.87         7810.8     10384.13   13796.04   Pony ORM
=============== ========== ========== ========== ============== ============ ========== ==========

=============== ========== ========== ========== ============== ============ ========== ==========
Test 2          Django     peewee     Pony ORM   SQLAlchemy ORM Tortoise ORM Max        Best ORM
=============== ========== ========== ========== ============== ============ ========== ==========
Insert: Single     1603.20    1518.01    1366.84         639.81      2729.39    2729.39 Tortoise ORM
Insert: Batch      2134.59    2066.40    3048.32        2545.23      4736.92    4736.92 Tortoise ORM
Insert: Bulk       6111.03    7410.69          —        2849.14     11125.47   11125.47 Tortoise ORM
Filter: Large     48881.43   39960.59   89456.54       38035.75     28527.89   89456.54   Pony ORM
Filter: Small     16270.99   14719.10   10436.38        9513.62     14871.59   16270.99     Django
Get                1687.23    1813.92    4383.75        1417.42      1860.83    4383.75   Pony ORM
Filter: dict      62701.38   58977.24   63025.33       36017.55     48697.93   63025.33   Pony ORM
Filter: tuple     64322.25   60028.11   89385.05       49882.11     44489.63   89385.05   Pony ORM
Update: Whole      1907.41    2275.28    3875.24        2587.80      6304.31    6304.31 Tortoise ORM
Update: Partial    1953.96    2889.56    4886.90        3491.98      8005.77    8005.77 Tortoise ORM
Delete              499.30    3714.41    3925.60         505.94      7657.41    7657.41 Tortoise ORM
Geometric Mean     5710.61    7051.76    9668.97        4600.72      9954.27   13129.29 Tortoise ORM
=============== ========== ========== ========== ============== ============ ========== ==========

=============== ========== ========== ========== ============== ============ ========== ==========
Test 3          Django     peewee     Pony ORM   SQLAlchemy ORM Tortoise ORM Max        Best ORM
=============== ========== ========== ========== ============== ============ ========== ==========
Insert: Single     1055.84    1003.80     313.76         731.76      1697.51    1697.51 Tortoise ORM
Insert: Batch      1290.10    1236.93     507.59        2009.35      2333.46    2333.46 Tortoise ORM
Insert: Bulk       2384.48    3072.91          —        2794.81      3252.96    3252.96 Tortoise ORM
Filter: Large     16549.49   11481.91   10598.41       16564.68      9942.77   16564.68 SQLAlchemy ORM
Filter: Small      8016.03    5649.40    1206.40        8036.68      6462.46    8036.68 SQLAlchemy ORM
Get                1016.49     689.32     896.93        1202.90      1142.02    1202.90 SQLAlchemy ORM
Filter: dict      19840.48   16554.79    5205.86       14468.71     15746.04   19840.48     Django
Filter: tuple     21360.02   17184.98   32516.25       20811.76     13860.57   32516.25   Pony ORM
Update: Whole      1116.56     752.64    3607.71        2597.76      3944.66    3944.66 Tortoise ORM
Update: Partial    2050.26    2917.96    4284.56        3528.72      7851.87    7851.87 Tortoise ORM
Delete             2360.26    4165.19    6013.99        4296.91      9070.12    9070.12 Tortoise ORM
Geometric Mean     3512.12    3261.34    2791.58        4232.33      5078.64    6016.56 Tortoise ORM
=============== ========== ========== ========== ============== ============ ========== ==========

