defmodule ESx.Test.Support.Migrations.CreateRepo do
  use Ecto.Migration

  def change do
    create table(:repos) do
      add :title, :string

      timestamps()
    end
  end

end
