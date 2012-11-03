#!/usr/bin/env ruby
# encoding: UTF-8

require 'date'

class Item
	include Comparable

	attr_accessor :id
	attr_accessor :prio
	attr_accessor :when
	attr_accessor :warn
	attr_accessor :what
	attr_accessor :content
	attr_accessor :timetype

	def initialize
		@id = 0
		@prio = 0
		@when = Time.local(2037)
		@warn = 1
		@what = ''
		@content = content
		@timetype = :none
	end

	def classify
		now = Time.now
		if now > @when
			return :dead
		elsif now > @when - @warn * 3600
			return :close
		else
			return :normal
		end
	end

	def to_s
		case classify
		when :dead
			print('! ')
		when :close
			print('* ')
		else
			print('  ')
		end

		printf('[%3s]', @prio.to_s)

		print(' [')
		case @timetype
		when :none
			print('                   ')
		when :time
			print('           ' + @when.strftime('%T'))
		when :date
			print(@when.strftime('%F') + '         ')
		when :datetime
			print(@when.strftime('%F %T'))
		end
		print(']')

		printf(' [%4s]', @id.to_s)

		print(' ' + @what)
	end

	def <=>(other)
		[@prio, @when] <=> [other.prio, other.when]
	end
end

def load_all(dir)
	items = []

	Dir.glob(dir + '/i*').each do |filename|
		f = File.new(filename, 'r')
		lines = f.readlines()
		f.close()

		item = Item.new

		filename =~ /.*i0*([[:digit:]]+)$/
		item.id = $1

		item.content = lines.join('')

		lines.each do |line|
			if line =~ /^(prio): (.*)/
				item.prio = $2.to_i
			elsif line =~ /^(when|dead): (.*)/
				item.when = DateTime.parse($2)
				item.when -= Time.now.utc_offset / 86400.0
				item.when = item.when.to_time

				spaces = $2.count(' ')
				colons = $2.count(':')
				case spaces
				when 0
					if colons > 0
						item.timetype = :time
					else
						item.timetype = :date
					end
				else
					item.timetype = :datetime
				end
			elsif line =~ /^(warn): (.*)/
				item.warn = $2.to_i
			elsif line =~ /^(what|subject): (.*)/
				item.what = $2
			end
		end

		items << item
	end

	items.sort!

	return items
end

def checkrepo(dir)
	Dir.exists?(dir + '/.git')
end

def pretty_print(items)
	puts 'O Prio        Deadline          ID   Subject'
	puts '- ----- --------------------- ------ -------'
	items.each do |i|
		puts i.to_s
	end
end


default_prefix = ENV['XDG_DATA_HOME'] || (ENV['HOME'] + '/.local/share')
datadir = ENV['GITODO_DATA'] || (default_prefix + '/gitodo.items')
editor = ENV['EDITOR'] || 'vim'

checkrepo(datadir) || exit(1)
items = load_all(datadir)

if ARGV.size == 0
	pretty_print(items)
	exit
end
