defmodule Wingman.Repo.Migrations.CreateMovieTag do
  use Ecto.Migration

  def change do
    # 标签组
    create table(:movie_tag_groups) do
      add :title, :string, null: false

      timestamps()
    end

    create unique_index(:movie_tag_groups, [:title])


    # 标签
    create table(:movie_tags) do
      add :title, :string, null: false
      add :group_id, references(:movie_tag_groups, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:movie_tags, [:group_id])
    create unique_index(:movie_tags, [:title, :group_id])


    # 联表
    create table(:movie_films_tags, primary_key: false) do
      add :film_id, references(:movie_films, on_delete: :delete_all), null: false
      add :tag_id, references(:movie_tags, on_delete: :delete_all), null: false
    end

    create index(:movie_films_tags, [:film_id])
    create index(:movie_films_tags, [:tag_id])
    create unique_index(:movie_films_tags, [:film_id, :tag_id])
  end
end
