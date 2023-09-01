CREATE TABLE users (
    id VARCHAR(36) PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    email VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NULL,
    avatar_url VARCHAR(255) NULL
);

CREATE TABLE forms (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_open BOOLEAN NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT NULL,
    raw_instructions TEXT NOT NULL, -- provided by the user
    fields_guidance TEXT NOT NULL, -- the guidance we give the fill agent to guide the fill process
    fields_schema JSON NOT NULL -- the fields we've extracted from the raw_instructions
);

CREATE TABLE responses (
    id VARCHAR(36) PRIMARY KEY,
    form_id VARCHAR(36) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    fields JSON NOT NULL -- the fields from the field schema, with the user's responses
);


-- This trigger automatically creates a profile entry when a new user signs up via Supabase Auth.
-- See https://supabase.com/docs/guides/auth/managing-user-data#using-triggers for more details.
drop function if exists public.handle_new_user cascade;
create function public.handle_new_user()
returns trigger as $$
begin
  insert into public.users (id, created_at, updated_at, email, full_name, avatar_url)
  values (new.id, NOW(), NOW(), new.email, new.raw_user_meta_data ->> 'full_name',  new.raw_user_meta_data ->> 'avatar_url');
  return new;
end;
$$ language plpgsql security definer;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
