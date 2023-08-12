
# terrform 初学

文件展示的是一个创造东西的最终结果，如果 aws 资源中有这个，那么就不做什么；如果没有就会创建

- 只需要定义或声明所有
- 所以，可以在 main.tf 文件中一点点在原有基础上加配置，而不会破坏旧有资源

不创建，先预览看看改动情况

`terrform plan`

开始创建文件中的资源：

`terrform apply`

无需确认，自动执行 apply 操作

`terraform apply --auto-approve`

清理所有资源

`terraform destroy`

查看当前资源

`terrform state list`

查看某一种资源的属性，而不用去 UI 登录控制台

`terraform state show data.aws_vpc.existing_vpc`

---
通过 variable 在执行时自定义变量值，可以达到修改原有资源的目的（并且跳过用户提示）

- 之后，去 aws 控制台查看，会看到子网 cidr 变化成了自定义的
- 也可以 apply 时带上参数
- 如果已经在 terraform.tfvars 里配置了变量值，那么 apply 时会自动去 tfvars 文件里找

`terraform apply -var "subnet_cidr_block=10.0.11.0/24"`

不同环境的变量文件 dev、staging、prod 可以分开存储，然后 apply 时指定文件即可

`terraform apply -var-file terraform-dev.tfvars`

---
the example of terraform.tfvars like this:

可以使用本地的环境变量， `aws configure` 进行配置

- 查看当前的 AWS 相关的变量： `env | grep AWS`

```tfvars
access_secret_key = [ "value of access_key","value of secret_key"]

# vpc_cidr_block    = "10.0.0.0/16"
# subnet_cidr_block = "10.0.11.0/24"

# cidr_block = ["10.0.0.0/16","10.0.11.0/24"]
cidr_blocks = [ 
    {cidr_block = "10.0.0.0/16",name = "vpc-l01"},
    {cidr_block = "10.0.11.0/24",name = "subnet-l01"}
]

envrionment = "dev-l01"
```

# ref

[terraform-AWS Provider docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)