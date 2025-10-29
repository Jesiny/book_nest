# 📚 BookNest

BookNest is a Ruby on Rails application designed to help readers **organize their books**, **track their reading progress**, and **interact with an AI reading companion**.

## 🚀 Features

### 🧠 AI-Powered Book Companion

- Each book automatically gets its own AI chat, initialized with the book’s context.
- Users can:
  - Discuss their impressions of the book with the AI.
  - Get help writing summaries or reviews.
  - Generate ideas and reflections on what they’ve read.

### 📖 Book Management

- Create and manage Groups of books (e.g. “Self-development”, “To Read”, “2025 Reading Challenge”).
- Within each group:
  - Add, edit, or delete Books.
  - Track:
    - Title, Author, Cover
    - Resume (summary)
    - Rating (via a 5-star interactive component)
    - Status: TBR, Reading, Finished, DNF
    - Dates started and finished
    - Review

### 👥 Authentication

- Secure authentication using Devise.
- Each user has personal Groups and Books.

### 🎨 Frontend

- Built with:
  - TailwindCSS for styling
  - Flowbite for UI components
  - Stimulus for interactivity
  - esbuild and yarn for bundling assets

## 🛠️ Setup

1. Clone the repository and go into the project

```shell
git clone git@github.com:Jesiny/book_nest.git
cd booknest
```

2.  Install dependencies

```shell
bundle install
yarn install
```

3. Set up the database

```shell
bin/rails db:create db:migrate db:seed
```

4. Set up OpenAI API key in one of two ways:

- **Option 1** — _.env.local_

Create a _.env.local_ file at the root of the project and add:

```env
OPENAI_API_KEY=your_api_key_here
```

- **Option 2** — _Rails credentials_

In terminal, open your editor to edit the credential file.

```shell
# Will create the credentials file if it does not exist
EDITOR="code --wait" bin/rails credentials:edit --environment=development
```

In the file, add this and close it to be saved.

```yml
openai:
  api_key: "your_api_key_here"
```

5. Start the server

```shell
bin/dev
```
