Sessions in Redis
=================

Este modulo realiza a mudança do filestore do odoo para ser usado para usar as sessões com redis.

- Instale as bibliotecas usando pip3 install -r requirements.txt

Configuração
-------------

Session no redis é ativada usando variaveis de ambiente.

* ``ODOO_SESSION_REDIS`` has to be ``1`` or ``true``
* ``ODOO_SESSION_REDIS_HOST`` is the redis hostname (default is ``localhost``)
* ``ODOO_SESSION_REDIS_PORT`` is the redis port (default is ``6379``)
* ``ODOO_SESSION_REDIS_PASSWORD`` is the password for the AUTH command
  (optional)
* ``ODOO_SESSION_REDIS_URL`` is an alternative way to define the Redis server
  address. It's the preferred way when you're using the ``rediss://`` protocol.
* ``ODOO_SESSION_REDIS_PREFIX`` is the prefix for the session keys (optional)
* ``ODOO_SESSION_REDIS_EXPIRATION`` is the time in seconds before expiration of
  the sessions (default is 7 days)
* ``ODOO_SESSION_REDIS_EXPIRATION_ANONYMOUS`` is the time in seconds before expiration of
  the anonymous sessions (default is 3 hours)


As chaves estão definidas para ``session:<session id>``.
Quando um prefixo é definido, as chaves são``session:<prefix>:<session id>``

Este complemento deve ser adicionado nos complementos de todo o servidor com (``--load``):


``--load=web,session_redis``

Limitações
-----------

* O servidor precisa ser reiniciado para funcionamento
* Os usúarios precisam logar novamente.
* O addon monkey-patch `` odoo.http.Root.session_store`` com um custom
  método quando o modo Redis está ativo, portanto, incompatibilidades com outros addons é possível se eles fizerem o mesmo..

Obs: Este modulo foi desenvolvido até o momento para odoo 13. porem está sendo usado no odoo 14 sem mais problemas. porem algumas funcionalidades estão com aviso de depreciação e precisam ser alteradas.