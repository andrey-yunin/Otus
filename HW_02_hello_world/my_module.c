#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt

#include <linux/init.h>
#include <linux/kernel.h>
#include <linux/module.h>

#define MY_STR_LEN 13
#define MY_STR_SIZE (MY_STR_LEN + 1)
#define ASCII_MIN 32
#define ASCII_MAX 126

static unsigned int idx;
static unsigned int ch_val;
static char my_str[MY_STR_SIZE];

static int idx_set(const char *val, const struct kernel_param *kp) {
  unsigned int new_idx;
  int ret;

  ret = kstrtouint(val, 10, &new_idx);
  if (ret)
    return ret;

  if (new_idx >= MY_STR_LEN)
    return -EINVAL;

  idx = new_idx;
  return 0;
}

static int idx_get(char *val, const struct kernel_param *kp) {
  return sprintf(val, "%u\n", idx);
}

static const struct kernel_param_ops idx_ops = {
    .set = idx_set,
    .get = idx_get,
};

module_param_cb(idx, &idx_ops, &idx, 0644);
MODULE_PARM_DESC(idx, "Index in my_str buffer");

static int ch_val_set(const char *val, const struct kernel_param *kp) {
  unsigned int new_ch_val;
  int ret;

  ret = kstrtouint(val, 10, &new_ch_val);
  if (ret)
    return ret;

  if (new_ch_val < ASCII_MIN || new_ch_val > ASCII_MAX)
    return -EINVAL;

  ch_val = new_ch_val;
  my_str[idx] = (char)ch_val;

  return 0;
}

static int ch_val_get(char *val, const struct kernel_param *kp) {
  return sprintf(val, "%u\n", ch_val);
}

static const struct kernel_param_ops ch_val_ops = {
    .set = ch_val_set,
    .get = ch_val_get,
};

module_param_cb(ch_val, &ch_val_ops, &ch_val, 0644);
MODULE_PARM_DESC(ch_val, "ASCII code of character to write");

static int my_str_get(char *val, const struct kernel_param *kp) {
  return sprintf(val, "%s\n", my_str);
}

static const struct kernel_param_ops my_str_ops = {
    .get = my_str_get,
};

module_param_cb(my_str, &my_str_ops, NULL, 0444);
MODULE_PARM_DESC(my_str, "Current string buffer");

static int __init hello_init(void) {
  pr_info("init\n");
  return 0;
}

static void __exit hello_exit(void) { pr_info("exit\n"); }

module_init(hello_init);
module_exit(hello_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Andrey Yunin");
MODULE_DESCRIPTION("Simple print module");
MODULE_VERSION("1.2");