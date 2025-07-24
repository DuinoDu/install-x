实现一个mcp server (FastMCP)，用于安装库，包括且不限于c cpp python rust js等。提供两个接口：
1. is_supported(library_name)，用于查询库是否支持安装
2. install(library_name), 在当前路径下安装这个库
用python实现，并提供单元测试代码，测试代码以numpy这个库的安装为例。
实现之前，先用rye创建一个python工程，python版本3.10，在rye创建的虚拟环境中测试代码。
