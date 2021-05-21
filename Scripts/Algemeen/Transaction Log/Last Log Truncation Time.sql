select [Checkpoint Begin]
from sys.fn_dblog (null, null)
where Operation = 'LOP_BEGIN_CKPT';