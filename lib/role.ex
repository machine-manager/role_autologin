alias Converge.{Util, All, DirectoryEmpty, FilePresent}

defmodule RoleAutologin do
	import Util, only: [conf_dir: 1]

	def role(tags \\ []) do
		autologin_user = get_autologin_user(tags)
		lightdm_conf   =
			"""
			[Seat:*]
			autologin-user=#{autologin_user}
			user-session=xfce
			"""
		post_install_unit = %All{units: [
			conf_dir("/etc/lightdm"),
			conf_dir("/etc/lightdm/lightdm.conf.d"),
			%DirectoryEmpty{path: "/etc/lightdm/lightdm.conf.d"},
			%FilePresent{path: "/etc/lightdm/lightdm.conf", content: lightdm_conf, mode: 0o644},
		]}
		%{
			desired_packages:  ["lightdm", "lightdm-gtk-greeter"],
			post_install_unit: post_install_unit,
		}
	end

	defp get_autologin_user(tags) do
		match = Enum.find(tags, fn tag -> tag |> String.starts_with?("autologin_user:") end)
		[_, user] = String.split(match, ":", parts: 2)
		user
	end
end
