# 安装过程

1. 准备磁盘

```sh
./x64/01-disk.sh
```

2. 检查环境

```sh
./x64/02-check.sh
```

3-4. 创建目录等

```sh
./x64/03-ch2.sh
./x64/04-ch4-dir.sh
```

5. 导出 packages.csv

```sh
./x64/packages.sh
```

6. 安装编译工具链

```sh
./x64/06-ch5.sh
```

7. 安装其他工具

```sh
./x64/07-ch6.sh
```

8. 创建目录

```sh
./x64/08-ch7.sh
```

9. 开启一个新的交互模式的 shell, 进入 chroot 环境

```sh
sudo mkdir /mnt/lfs/lfs
# 为了能够在 chroot 后依然能访问当前目录
sudo mount -v --bind `pwd` /mnt/lfs/lfs
source ./x64/09-ch7-chroot.sh
```

10. 

