SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Booking](
	[Id] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[CruiseId] [uniqueidentifier] NOT NULL,
	[Reference] [nvarchar](8) NOT NULL,
	[FirstName] [nvarchar](64) NOT NULL,
	[LastName] [nvarchar](64) NOT NULL,
	[Email] [nvarchar](64) NOT NULL,
	[PhoneNo] [nvarchar](64) NOT NULL,
	[Lunch] [nvarchar](5) NOT NULL,
	[Discount] [tinyint] NOT NULL,
	[TotalPrice] [decimal](8, 2) NOT NULL,
	[IsLocked] [bit] NOT NULL,
	[InternalNotes] [nvarchar](2048) NOT NULL,
	[SubCruise] [nvarchar](3) NOT NULL,
	[Created] [datetime2](3) NOT NULL,
	[Updated] [datetime2](3) NOT NULL,
 CONSTRAINT [PK_Booking] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UK_Booking_Reference] UNIQUE NONCLUSTERED 
(
	[Reference] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BookingCabin](
	[Id] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[CruiseId] [uniqueidentifier] NOT NULL,
	[BookingId] [uniqueidentifier] NOT NULL,
	[CabinTypeId] [uniqueidentifier] NOT NULL,
	[Order] [tinyint] NOT NULL,
 CONSTRAINT [PK_BookingCabin] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BookingChange](
	[Id] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[BookingId] [uniqueidentifier] NOT NULL,
	[CabinIndex] [smallint] NOT NULL,
	[PaxIndex] [smallint] NOT NULL,
	[FieldName] [nvarchar](64) NOT NULL,
	[Updated] [datetime2](3) NOT NULL,
 CONSTRAINT [PK_BookingChange] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BookingPax](
	[Id] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[BookingCabinId] [uniqueidentifier] NOT NULL,
	[Group] [nvarchar](256) NOT NULL,
	[FirstName] [nvarchar](256) NOT NULL,
	[LastName] [nvarchar](256) NOT NULL,
	[Gender] [nchar](1) NOT NULL,
	[Dob] [nchar](6) NOT NULL,
	[Nationality] [nchar](2) NOT NULL,
	[Years] [int] NOT NULL,
	[Order] [tinyint] NOT NULL,
 CONSTRAINT [PK_BookingPax] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BookingPayment](
	[Id] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[BookingId] [uniqueidentifier] NOT NULL,
	[Amount] [decimal](8, 2) NOT NULL,
	[Created] [datetime2](3) NOT NULL,
 CONSTRAINT [PK_BookingPayment] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BookingProduct](
	[Id] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[CruiseId] [uniqueidentifier] NOT NULL,
	[BookingId] [uniqueidentifier] NOT NULL,
	[ProductTypeId] [uniqueidentifier] NOT NULL,
	[Quantity] [int] NOT NULL,
 CONSTRAINT [PK_BookingProduct] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CabinType](
	[Id] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[SubCruise] [nvarchar](3) NOT NULL,
	[Name] [nvarchar](16) NOT NULL,
	[Description] [nvarchar](2048) NOT NULL,
	[Capacity] [int] NOT NULL,
	[Order] [tinyint] NOT NULL,
 CONSTRAINT [PK_CabinType] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Cruise](
	[Id] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[Name] [nvarchar](64) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsLocked] [bit] NOT NULL,
 CONSTRAINT [PK_Cruise] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CruiseCabin](
	[CruiseId] [uniqueidentifier] NOT NULL,
	[CabinTypeId] [uniqueidentifier] NOT NULL,
	[Count] [int] NOT NULL,
	[PricePerPax] [decimal](8, 2) NOT NULL,
 CONSTRAINT [PK_CruiseCabin] PRIMARY KEY CLUSTERED 
(
	[CruiseId] ASC,
	[CabinTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CruiseProduct](
	[CruiseId] [uniqueidentifier] NOT NULL,
	[ProductTypeId] [uniqueidentifier] NOT NULL,
	[Description] [nvarchar](2048) NOT NULL,
	[Count] [int] NOT NULL,
	[Price] [decimal](8, 2) NOT NULL,
 CONSTRAINT [PK_CruiseProduct] PRIMARY KEY CLUSTERED 
(
	[CruiseId] ASC,
	[ProductTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [DeletedBooking](
	[Id] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[CruiseId] [uniqueidentifier] NOT NULL,
	[Reference] [nvarchar](8) NOT NULL,
	[FirstName] [nvarchar](64) NOT NULL,
	[LastName] [nvarchar](64) NOT NULL,
	[Email] [nvarchar](64) NOT NULL,
	[PhoneNo] [nvarchar](64) NOT NULL,
	[TotalPrice] [decimal](8, 2) NOT NULL,
	[AmountPaid] [decimal](8, 2) NOT NULL,
	[Created] [datetime2](3) NOT NULL,
	[Updated] [datetime2](3) NOT NULL,
	[Deleted] [datetime2](3) NOT NULL,
 CONSTRAINT [PK_DeletedBooking] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Log](
	[Idx] [int] IDENTITY(1,1) NOT NULL,
	[Timestamp] [datetime] NOT NULL,
	[Level] [nvarchar](16) NOT NULL,
	[Logger] [nvarchar](64) NOT NULL,
	[Message] [nvarchar](max) NOT NULL,
	[Callsite] [nvarchar](max) NULL,
	[Exception] [nvarchar](max) NULL,
	[UserName] [nvarchar](16) NULL,
	[Method] [nvarchar](8) NULL,
	[Url] [nvarchar](max) NULL,
	[RemoteAddress] [nvarchar](64) NULL,
	[LocalAddress] [nvarchar](64) NULL,
 CONSTRAINT [PK_Log] PRIMARY KEY CLUSTERED 
(
	[Idx] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ProductType](
	[Id] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[Name] [nvarchar](255) NOT NULL,
	[Image] [nvarchar](64) NULL,
	[Order] [tinyint] NOT NULL,
 CONSTRAINT [PK_ProductType] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Report](
	[Id] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[CruiseId] [uniqueidentifier] NOT NULL,
	[SubCruise] [nvarchar](3) NOT NULL,
	[Date] [date] NOT NULL,
	[BookingsCreated] [int] NOT NULL,
	[BookingsTotal] [int] NOT NULL,
	[CabinsTotal] [int] NOT NULL,
	[PaxTotal] [int] NOT NULL,
	[CapacityTotal] [int] NOT NULL,
	[Created] [datetime2](3) NOT NULL,
 CONSTRAINT [PK_Report] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UK_Report] UNIQUE NONCLUSTERED 
(
	[CruiseId] ASC,
	[SubCruise] ASC,
	[Date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SubCruise](
	[CruiseId] [uniqueidentifier] NOT NULL,
	[Code] [nvarchar](3) NOT NULL,
	[Name] [nvarchar](64) NOT NULL,
	[Order] [tinyint] NOT NULL,
 CONSTRAINT [PK_SubCruise] PRIMARY KEY CLUSTERED 
(
	[CruiseId] ASC,
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [User](
	[Id] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[UserName] [nvarchar](16) NOT NULL,
	[PasswordHash] [nvarchar](1024) NOT NULL,
	[SecurityStamp] [nvarchar](1024) NOT NULL,
	[ResetToken] [nvarchar](1024) NULL,
	[IsBooking] [bit] NOT NULL,
 CONSTRAINT [PK_User] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UK_User_UserName] UNIQUE NONCLUSTERED 
(
	[UserName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Booking_CruiseId] ON [Booking]
(
	[CruiseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_BookingCabin_BookingId] ON [BookingCabin]
(
	[BookingId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_BookingChange_BookingId] ON [BookingChange]
(
	[BookingId] ASC,
	[Updated] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_BookingPax_BookingCabinId] ON [BookingPax]
(
	[BookingCabinId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_BookingPayment_BookingId] ON [BookingPayment]
(
	[BookingId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_BookingProduct_BookingId] ON [BookingProduct]
(
	[BookingId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_DeletedBooking_CruiseId] ON [DeletedBooking]
(
	[CruiseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [Booking] ADD  CONSTRAINT [DF_Booking_Id]  DEFAULT (newsequentialid()) FOR [Id]
GO
ALTER TABLE [Booking] ADD  CONSTRAINT [DF_Booking_Discount]  DEFAULT ((0)) FOR [Discount]
GO
ALTER TABLE [Booking] ADD  CONSTRAINT [DF_Booking_TotalPrice]  DEFAULT ((0)) FOR [TotalPrice]
GO
ALTER TABLE [Booking] ADD  CONSTRAINT [DF_Booking_IsLocked]  DEFAULT ((0)) FOR [IsLocked]
GO
ALTER TABLE [Booking] ADD  CONSTRAINT [DF_Booking_InternalNotes]  DEFAULT ('') FOR [InternalNotes]
GO
ALTER TABLE [Booking] ADD  CONSTRAINT [DF_Booking_Created]  DEFAULT (sysdatetime()) FOR [Created]
GO
ALTER TABLE [Booking] ADD  CONSTRAINT [DF_Booking_Updated]  DEFAULT (sysdatetime()) FOR [Updated]
GO
ALTER TABLE [BookingCabin] ADD  CONSTRAINT [DF_BookingCabin_Id]  DEFAULT (newsequentialid()) FOR [Id]
GO
ALTER TABLE [BookingChange] ADD  CONSTRAINT [DF_BookingChange_Id]  DEFAULT (newsequentialid()) FOR [Id]
GO
ALTER TABLE [BookingChange] ADD  CONSTRAINT [DF_BookingChange_Updated]  DEFAULT (sysdatetime()) FOR [Updated]
GO
ALTER TABLE [BookingPax] ADD  CONSTRAINT [DF_BookingPax_Id]  DEFAULT (newsequentialid()) FOR [Id]
GO
ALTER TABLE [BookingPayment] ADD  CONSTRAINT [DF_BookingPayment_Id]  DEFAULT (newsequentialid()) FOR [Id]
GO
ALTER TABLE [BookingPayment] ADD  CONSTRAINT [DF_BookingPayment_Created]  DEFAULT (sysdatetime()) FOR [Created]
GO
ALTER TABLE [BookingProduct] ADD  CONSTRAINT [DF_BookingProduct_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [CabinType] ADD  CONSTRAINT [DF_CabinType_Id]  DEFAULT (newsequentialid()) FOR [Id]
GO
ALTER TABLE [CabinType] ADD  CONSTRAINT [DF_CabinType_SubCruise]  DEFAULT ('A') FOR [SubCruise]
GO
ALTER TABLE [CabinType] ADD  CONSTRAINT [DF_CabinType_Order]  DEFAULT ((255)) FOR [Order]
GO
ALTER TABLE [Cruise] ADD  CONSTRAINT [DF_Cruise_Id]  DEFAULT (newsequentialid()) FOR [Id]
GO
ALTER TABLE [Cruise] ADD  CONSTRAINT [DF_Cruise_IsLocked]  DEFAULT ((0)) FOR [IsLocked]
GO
ALTER TABLE [CruiseProduct] ADD  CONSTRAINT [DF_CruiseProduct_Count]  DEFAULT ((-1)) FOR [Count]
GO
ALTER TABLE [DeletedBooking] ADD  CONSTRAINT [DF_DeletedBooking_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [DeletedBooking] ADD  CONSTRAINT [DF_DeletedBooking_Deleted]  DEFAULT (sysdatetime()) FOR [Deleted]
GO
ALTER TABLE [ProductType] ADD  CONSTRAINT [DF_ProductType_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [ProductType] ADD  CONSTRAINT [DF_ProductType_Order]  DEFAULT ((255)) FOR [Order]
GO
ALTER TABLE [Report] ADD  CONSTRAINT [DF_Report_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [Report] ADD  CONSTRAINT [DF_Report_Created]  DEFAULT (sysdatetime()) FOR [Created]
GO
ALTER TABLE [User] ADD  CONSTRAINT [DF_User_Id]  DEFAULT (newsequentialid()) FOR [Id]
GO
ALTER TABLE [User] ADD  CONSTRAINT [DF_User_PasswordHash]  DEFAULT ('') FOR [PasswordHash]
GO
ALTER TABLE [User] ADD  CONSTRAINT [DF_User_SecurityStamp]  DEFAULT ('') FOR [SecurityStamp]
GO
ALTER TABLE [User] ADD  CONSTRAINT [DF_User_IsBooking]  DEFAULT ((0)) FOR [IsBooking]
GO
ALTER TABLE [Booking]  WITH CHECK ADD  CONSTRAINT [FK_Booking_Cruise] FOREIGN KEY([CruiseId])
REFERENCES [Cruise] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [Booking] CHECK CONSTRAINT [FK_Booking_Cruise]
GO
ALTER TABLE [BookingCabin]  WITH CHECK ADD  CONSTRAINT [FK_BookingCabin_Booking] FOREIGN KEY([BookingId])
REFERENCES [Booking] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [BookingCabin] CHECK CONSTRAINT [FK_BookingCabin_Booking]
GO
ALTER TABLE [BookingCabin]  WITH CHECK ADD  CONSTRAINT [FK_BookingCabin_CabinType] FOREIGN KEY([CabinTypeId])
REFERENCES [CabinType] ([Id])
GO
ALTER TABLE [BookingCabin] CHECK CONSTRAINT [FK_BookingCabin_CabinType]
GO
ALTER TABLE [BookingCabin]  WITH CHECK ADD  CONSTRAINT [FK_BookingCabin_Cruise] FOREIGN KEY([CruiseId])
REFERENCES [Cruise] ([Id])
GO
ALTER TABLE [BookingCabin] CHECK CONSTRAINT [FK_BookingCabin_Cruise]
GO
ALTER TABLE [BookingChange]  WITH CHECK ADD  CONSTRAINT [FK_BookingChange_Booking] FOREIGN KEY([BookingId])
REFERENCES [Booking] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [BookingChange] CHECK CONSTRAINT [FK_BookingChange_Booking]
GO
ALTER TABLE [BookingPax]  WITH CHECK ADD  CONSTRAINT [FK_BookingPax_BookingCabin] FOREIGN KEY([BookingCabinId])
REFERENCES [BookingCabin] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [BookingPax] CHECK CONSTRAINT [FK_BookingPax_BookingCabin]
GO
ALTER TABLE [BookingPayment]  WITH CHECK ADD  CONSTRAINT [FK_BookingPayment_Booking] FOREIGN KEY([BookingId])
REFERENCES [Booking] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [BookingPayment] CHECK CONSTRAINT [FK_BookingPayment_Booking]
GO
ALTER TABLE [BookingProduct]  WITH CHECK ADD  CONSTRAINT [FK_BookingProduct_Booking] FOREIGN KEY([BookingId])
REFERENCES [Booking] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [BookingProduct] CHECK CONSTRAINT [FK_BookingProduct_Booking]
GO
ALTER TABLE [BookingProduct]  WITH CHECK ADD  CONSTRAINT [FK_BookingProduct_Cruise] FOREIGN KEY([CruiseId])
REFERENCES [Cruise] ([Id])
GO
ALTER TABLE [BookingProduct] CHECK CONSTRAINT [FK_BookingProduct_Cruise]
GO
ALTER TABLE [BookingProduct]  WITH CHECK ADD  CONSTRAINT [FK_BookingProduct_ProductType] FOREIGN KEY([ProductTypeId])
REFERENCES [ProductType] ([Id])
GO
ALTER TABLE [BookingProduct] CHECK CONSTRAINT [FK_BookingProduct_ProductType]
GO
ALTER TABLE [CruiseCabin]  WITH CHECK ADD  CONSTRAINT [FK_CruiseCabin_CabinType] FOREIGN KEY([CabinTypeId])
REFERENCES [CabinType] ([Id])
GO
ALTER TABLE [CruiseCabin] CHECK CONSTRAINT [FK_CruiseCabin_CabinType]
GO
ALTER TABLE [CruiseCabin]  WITH CHECK ADD  CONSTRAINT [FK_CruiseCabin_Cruise] FOREIGN KEY([CruiseId])
REFERENCES [Cruise] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [CruiseCabin] CHECK CONSTRAINT [FK_CruiseCabin_Cruise]
GO
ALTER TABLE [CruiseProduct]  WITH CHECK ADD  CONSTRAINT [FK_CruiseProduct_Cruise] FOREIGN KEY([CruiseId])
REFERENCES [Cruise] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [CruiseProduct] CHECK CONSTRAINT [FK_CruiseProduct_Cruise]
GO
ALTER TABLE [CruiseProduct]  WITH CHECK ADD  CONSTRAINT [FK_CruiseProduct_ProductType] FOREIGN KEY([ProductTypeId])
REFERENCES [ProductType] ([Id])
GO
ALTER TABLE [CruiseProduct] CHECK CONSTRAINT [FK_CruiseProduct_ProductType]
GO
ALTER TABLE [DeletedBooking]  WITH CHECK ADD  CONSTRAINT [FK_DeletedBooking_Cruise] FOREIGN KEY([CruiseId])
REFERENCES [Cruise] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [DeletedBooking] CHECK CONSTRAINT [FK_DeletedBooking_Cruise]
GO
ALTER TABLE [Report]  WITH CHECK ADD  CONSTRAINT [FK_Report_Cruise] FOREIGN KEY([CruiseId])
REFERENCES [Cruise] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [Report] CHECK CONSTRAINT [FK_Report_Cruise]
GO
ALTER TABLE [SubCruise]  WITH CHECK ADD  CONSTRAINT [FK_SubCruise_Cruise] FOREIGN KEY([CruiseId])
REFERENCES [Cruise] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [SubCruise] CHECK CONSTRAINT [FK_SubCruise_Cruise]
GO
