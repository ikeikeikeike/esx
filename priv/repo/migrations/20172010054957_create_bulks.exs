defmodule ESx.Test.Support.Migrations.CreateRepo do
  use Ecto.Migration

  def change do
    create table(:bulks) do
      add :title, :string
    end
  end

end
