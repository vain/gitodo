#!/usr/bin/env ruby
# encoding: UTF-8

require 'date'

module Colors
	@table = {
		:dead      => ['tput bold; tput setaf 1', nil],
		:close     => ['tput setaf 1', nil],
		:very_high => ['tput bold; tput setaf 1', nil],
		:high      => ['tput setaf 1', nil],
		:low       => ['tput setaf 4', nil],
		:very_low  => ['tput setaf 2', nil],
		:header    => ['tput bold', nil],
		:reset     => ['tput sgr0', nil],
	}

	def Colors.[](which)
		if not STDOUT.tty?
			return ''
		end

		# Lazy allocation to save useless forks.
		if @table[which][1] == nil
			@table[which][1] = `#{@table[which][0]}`
		end

		return @table[which][1]
	end
end

class Item
	include Comparable

	attr_accessor :id
	attr_accessor :filename
	attr_accessor :prio
	attr_accessor :when
	attr_accessor :warn
	attr_accessor :what
	attr_accessor :nocron
	attr_accessor :content
	attr_accessor :timetype

	def initialize
		@id = 0
		@filename = ''
		@prio = 0
		@when = Time.local(2037)
		@warn = 1
		@what = ''
		@nocron = false
		@content = ''
		@timetype = :none
	end

	def id_fmt
		'%04d' % @id
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

	def timetype_num
		case @timetype
		when :time
			0
		when :date
			1
		when :datetime
			2
		else
			3
		end
	end

	def show_brief
		case classify
		when :dead
			print(Colors[:dead])
			print('! ')
		when :close
			print(Colors[:close])
			print('* ')
		else
			print('  ')
		end

		print(Colors[:reset])

		if prio < -5
			print(Colors[:very_high])
		elsif prio < 0
			print(Colors[:high])
		elsif prio > 5
			print(Colors[:low])
		elsif prio > 0
			print(Colors[:very_low])
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
		print(Colors[:reset])

		puts
	end

	def show_detail
		print(Colors[:header])
		puts(id_fmt)
		puts(id_fmt.gsub(/./, '-'))
		print(Colors[:reset])
		puts

		puts(@content)

		puts
	end

	def show_raw
		print("#{@prio} #{@when.strftime('%F %T %s')} ")
		print("#{@warn} #{@nocron ? '1' : '0'} #{timetype_num} ")
		print("#{@id} #{@what}")

		puts
	end

	def <=>(other)
		[@prio, @when] <=> [other.prio, other.when]
	end
end

def load_all_items
	items = []

	Dir.glob('i*').each do |filename|
		f = File.new(filename, 'r')
		lines = f.readlines()
		f.close()

		item = Item.new

		filename =~ /.*i0*([[:digit:]]+)$/
		item.id = $1
		item.filename = filename

		item.content = lines.join('')

		lines.each do |line|
			if line =~ /^(prio): (.*)/
				item.prio = $2.to_i
			elsif line =~ /^(when|dead): (.*)/
				# XXX: Hackaround to be able to use DateTime.parse in
				# the local timezone.
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
			elsif line == 'nocron'
				item.nocron = true
			end
		end

		items << item
	end

	items.sort!

	return items
end

def check_and_chdir_repo(dir)
	if Dir.exists?(dir + '/.git')
		Dir.chdir(dir)
	end
end

def print_header(indent=false)
	print(Colors[:header])
	puts((indent ? "\t" : '') + 'O Prio        Deadline          ID   Subject')
	puts((indent ? "\t" : '') + '- ----- --------------------- ------ -------')
	print(Colors[:reset])
end

def list_items(items, indent=false)
	print_header(indent)
	items.each do |i|
		if indent
			print("\t")
		end
		i.show_brief
	end
end

def print_items(items)
	items.each do |i|
		i.show_detail
	end
end

def filter_ids(items, filter)
	# TODO: This works but feels very odd.
	items.select do |i|
		match = false
		filter.each do |f|
			if f.start_with?(':/')
				if i.what =~ /#{f[2..-1]}/i
					match = true
					next
				end
			elsif f == 'dead'
				if i.classify == :dead
					match = true
					next
				end
			elsif f == 'close'
				if i.classify == :close
					match = true
					next
				end
			else
				if i.id == f
					match = true
					next
				end
			end
		end
		match
	end
end

def filter_bodies(items, filter)
	items.select { |i| i.content =~ /#{filter}/i }
end

def filter_rotting(items, months)
	now = Time.now
	items.select do |i|
		lchange = `git log '--pretty=format:%ct' -n 1 -- "#{i.filename}"`
		lchange = Time.at(lchange.to_i)
		now - lchange > months * 60 * 60 * 24 * 30
	end
end

def print_cron(items, selection)
	puts('OUTDATED TASKS:')
	puts('===============')
	puts
	list_items(filter_ids(items, ['dead']), true)

	if selection == :all
		puts
		puts

		puts('DEADLINE CLOSE:')
		puts('===============')
		puts
		list_items(filter_ids(items, ['close']), true)
	end
end

def new_items(editor, how_many)
	how_many.times do
		filename = 'i' + ('%04d' % rand(0..9999))
		while File.exists? filename
			filename = 'i' + ('%04d' % rand(0..9999))
		end

		system "#{editor} #{filename}"
	end
end

def delete_items(items)
	items.each do |i|
		File.delete(i.filename)
	end
end

def commit
	system 'git add .'
	system 'git commit -a -m "Auto-commit $(hostname)."'
end


default_prefix = ENV['XDG_DATA_HOME'] || (ENV['HOME'] + '/.local/share')
datadir = ENV['GITODO_DATA'] || (default_prefix + '/gitodo.items')
editor = ENV['EDITOR'] || 'vim'

if not check_and_chdir_repo(datadir)
	$stderr.puts "`#{datadir}' is not a Git repository."
	exit 1
end
items = load_all_items

if ARGV.size == 0
	list_items(items)
	exit
end

opt = ARGV[0].sub(/^-+/, '')
ARGV.shift
case opt
when 'new', 'n'
	new_items(editor, ARGV[0] ? ARGV[0].to_i : 1)
	commit
when 'list', 'l'
	list_items(filter_ids(items, ARGV))
when 'print', 'p'
	print_items(filter_ids(items, ARGV))
when 'body', 'b'
	print_items(filter_bodies(items, ARGV[0]))
when 'edit', 'e'
	filter_ids(items, ARGV).each do |i|
		system "#{editor} #{i.filename}"
	end
	commit
when 'delete', 'd'
	filter_ids(items, ARGV).each do |i|
		puts "Deleting #{i.id_fmt}: #{i.what}"
		File.delete(i.filename)
	end
	commit
when 'count'
	total = items.size
	dead = items.count { |i| i.classify == :dead }
	close = items.count { |i| i.classify == :close }
	puts("#{dead} #{close} #{total}")
when 'cron', 'c'
	print_cron(items, :all)
when 'cron-outdated', 'o'
	print_cron(items, :no_close)
when 'raw'
	items.each { |i| i.show_raw }
when 'rotting'
	list_items(filter_rotting(items, ARGV[0] ? ARGV[0].to_i : 3))
else
	puts 'Invalid option. See manpage.'
end
