	class BlankObject
		instance_methods.each { |m| 
			undef_method m unless (m =~ /^__/ || m =~ /yaml/ || m == 'respond_to?' || m == 'taguri')
		}
	end