/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('usuario', {
		id_usuario: {
			type: DataTypes.INTEGER,
			allowNull: false,
			defaultValue: "nextval(id_usuario::regclass)",
			primaryKey: true
		},
		nombre: {
			type: DataTypes.STRING,
			allowNull: false
		},
		apellidos: {
			type: DataTypes.STRING,
			allowNull: true
		},
		institucion: {
			type: DataTypes.STRING,
			allowNull: true
		},
		departamento: {
			type: DataTypes.STRING,
			allowNull: true
		},
		posicion: {
			type: DataTypes.STRING,
			allowNull: true
		},
		estado: {
			type: DataTypes.STRING,
			allowNull: true
		},
		pass: {
			type: DataTypes.STRING,
			allowNull: true
		},
		avatar: {
			type: DataTypes.STRING,
			allowNull: true
		},
		email: {
			type: DataTypes.STRING,
			allowNull: true
		},
		email_adicional: {
			type: DataTypes.STRING,
			allowNull: true
		},
		biografia: {
			type: DataTypes.STRING,
			allowNull: true
		},
		telefono: {
			type: DataTypes.INTEGER,
			allowNull: true
		},
		skype: {
			type: DataTypes.STRING,
			allowNull: true
		},
		dni: {
			type: DataTypes.STRING,
			allowNull: true
		},
		fk_perfil_usuario: {
			type: DataTypes.INTEGER,
			allowNull: true,
			references: {
				model: 'perfil_usuario',
				key: 'id_perfil_usuario'
			}
		}
	}, {
		tableName: 'usuario',
		timestamps: false
	});
};
