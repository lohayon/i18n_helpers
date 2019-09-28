defmodule I18nHelpers.Form.InputHelpersTest do
  use ExUnit.Case, async: true

  alias I18nHelpers.Form.InputHelpers
  alias I18nHelpers.Ecto.TranslatableSchema

  import Phoenix.HTML
  import Phoenix.HTML.Form
  import Phoenix.HTML.Tag

  doctest InputHelpers

  defmodule Post do
    use Ecto.Schema
    use TranslatableSchema

    schema "posts" do
      translatable_field :title
      translatable_field :body
    end
  end

  defmodule MyGettext do
    use Gettext, otp_app: :i18n_helpers
  end

  defp conn do
    Plug.Test.conn(:get, "/")
  end

  test "generate textarea" do
    form =
      safe_to_string(
        form_for(conn(), "/", fn f ->
          InputHelpers.translated_textarea(f, :title, :fr)
        end)
      )

    assert form =~ ~s(<textarea id="title_fr" name="title[fr]"></textarea>)
  end

  test "generate text input" do
    form =
      safe_to_string(
        form_for(conn(), "/", fn f ->
          InputHelpers.translated_text_input(f, :title, :fr)
        end)
      )

    assert form =~ ~s(<input id="title_fr" name="title[fr]" type="text" value="">)

    refute form =~ ~s(</input>)
  end

  test "generate multiple text inputs" do
    form =
      safe_to_string(
        form_for(conn(), "/", fn f ->
          InputHelpers.translated_text_inputs(f, :title, [:en, :fr])
        end)
      )

    assert form =~
             ~s(<label for="title_en">en</label><input id="title_en" name="title[en]" type="text" value=""><label for="title_fr">fr</label><input id="title_fr" name="title[fr]" type="text" value="">)
  end

  test "generate multiple textareas" do
    form =
      safe_to_string(
        form_for(conn(), "/", fn f ->
          InputHelpers.translated_textareas(f, :title, [:en, :fr])
        end)
      )

    assert form =~
             ~s(<label for="title_en">en</label><textarea id="title_en" name="title[en]"></textarea><label for="title_fr">fr</label><textarea id="title_fr" name="title[fr]"></textarea>)
  end

  test "generate multiple textareas with Gettext backend" do
    form =
      safe_to_string(
        form_for(conn(), "/", fn f ->
          InputHelpers.translated_textareas(
            f,
            :title,
            I18nHelpers.Form.InputHelpersTest.MyGettext
          )
        end)
      )

    assert form =~
             ~s(<label for="title_fr">fr</label><textarea id="title_fr" name="title[fr]"></textarea>)
  end

  @tag :wip
  test "generate multiple textareas with custom labels" do
    form =
      safe_to_string(
        form_for(conn(), "/", fn f ->
          InputHelpers.translated_textareas(f, :title, [:en, :fr],
            labels: fn locale -> raw("<i>#{locale}</i>") end
          )
        end)
      )

    assert form =~
             ~s(<label for="title_en"><i>en</i></label><textarea id="title_en" name="title[en]"></textarea><label for="title_fr"><i>fr</i></label><textarea id="title_fr" name="title[fr]"></textarea>)
  end

  @tag :wip
  test "generate multiple text inputs with custom labels" do
    form =
      safe_to_string(
        form_for(conn(), "/", fn f ->
          InputHelpers.translated_text_inputs(f, :title, [:en, :fr],
            labels: fn locale -> {content_tag(:i, locale), class: "test"} end
          )
        end)
      )

    assert form =~
             ~s(<label class="test" for="title_en"><i>en</i></label><input id="title_en" name="title[en]" type="text" value=""><label class="test" for="title_fr"><i>fr</i></label><input id="title_fr" name="title[fr]" type="text" value="">)
  end

  test "generate multiple text inputs with wrapping container" do
    form =
      safe_to_string(
        form_for(conn(), "/", fn f ->
          InputHelpers.translated_text_inputs(f, :title, [:en, :fr],
            labels: fn locale -> content_tag(:i, locale) end,
            wrappers: fn _locale -> {:div, class: "test"} end
          )
        end)
      )

    assert form =~
             ~s(<div class="test"><label for="title_en"><i>en</i></label><input id="title_en" name="title[en]" type="text" value=""></div><div class="test"><label for="title_fr"><i>fr</i></label><input id="title_fr" name="title[fr]" type="text" value=""></div>)
  end
end
