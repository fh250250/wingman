# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Wingman.Repo.insert!(%Wingman.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

# 创建存储库根目录
Wingman.Repo.insert!(%Wingman.Storage.Folder{name: "root", lft: 1, rht: 2})
